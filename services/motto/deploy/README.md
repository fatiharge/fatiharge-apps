# Deploying motto

The release workflow builds a native image, pushes it to `ghcr.io`, copies
`compose.yaml` to the server, rewrites `MOTTO_IMAGE` to the digest it just
built, and runs `docker compose up -d`. Nothing else about the server lives in
this repository.

Production is handed the image stage has been running, by digest, and never
rebuilds. A rebuild from the same source produces a different artefact — a newer
base layer, a newer compiler patch — and that is what makes "it worked on stage"
stop meaning anything.

## What the server already provides

The box that serves `dafalabs.com` and `op.dafatek.com` runs Traefik on an
external Docker network called `reverse-proxy`, terminating TLS on the
`websecure` entrypoint with the `myresolver` certificate resolver.
`compose.yaml` defaults to exactly those three, so the `.env` only names them if
they ever change.

## 1. DNS

Both hosts point at the same server as everything else on it. Traefik cannot
obtain a certificate before the record resolves, so this comes first.

| Record | Type | Value |
|---|---|---|
| `motto.stage.dafalabs.com` | A | the server's address |
| `motto.dafalabs.com` | A | the server's address |

## 2. Directories on the server

One per environment, owned by the deploy user:

```bash
sudo install -d -o "$USER" -g "$USER" /srv/motto-stage /srv/motto-prod
```

## 3. `.env`, one per environment

Never committed, never leaves the server.

`/srv/motto-stage/.env`:

```dotenv
MOTTO_ENV=stage
MOTTO_PROFILE=stage
MOTTO_HOST=motto.stage.dafalabs.com
MOTTO_IMAGE=
MOTTO_DB_PASSWORD=<openssl rand -base64 24>
MOTTO_JWT_PUBLIC_KEY=
```

`/srv/motto-prod/.env` is the same with `prod`, `prod`,
`motto.dafalabs.com`, and its own password.

- `MOTTO_IMAGE` stays empty. Every deploy rewrites it.
- `MOTTO_JWT_PUBLIC_KEY` stays empty until `auth` is deployed. Nothing in motto
  is authenticated yet; an unset key costs a startup warning and nothing else.
- `PROXY_NETWORK`, `TRAEFIK_ENTRYPOINT` and `TRAEFIK_CERTRESOLVER` only need a
  line if the server's Traefik ever stops matching the defaults above.

**A trap worth knowing:** Quarkus profiles do not inherit. A property written as
`%prod.something` does **not** apply when `MOTTO_PROFILE=stage`. Anything both
environments need goes in unprefixed.

## 4. `known_hosts`

Pinned rather than scanned at deploy time: every CI run is a first connection,
so accepting whatever answers would accept anything. SSH is not on port 22 here,
so pass the real one:

```bash
ssh-keyscan -p <ssh-port> -H <host> 2>/dev/null
```

The whole output is the value of the `DEPLOY_KNOWN_HOSTS` secret.

## 5. What GitHub needs

Repository secrets — Settings → Secrets and variables → Actions → Secrets:

| Secret | What it is |
|---|---|
| `DEPLOY_HOST` | the server |
| `DEPLOY_PORT` | its SSH port |
| `DEPLOY_USER` | a user that may write the two compose directories and talk to Docker — not root |
| `DEPLOY_SSH_KEY` | that user's private key, whole file including the header line |
| `DEPLOY_KNOWN_HOSTS` | the output from step 4 |

Repository variable — the same page, Variables tab:

| Variable | What it does |
|---|---|
| `DEPLOY_ENABLED` | `true` once the server is ready. Until then a merge builds and pushes the image and stops, instead of failing at a deploy that cannot work yet. |

Environment variables — Settings → Environments, one environment named `stage`
and one named `production`, each with:

| Variable | `stage` | `production` |
|---|---|---|
| `DEPLOY_PATH` | `/srv/motto-stage` | `/srv/motto-prod` |
| `SERVICE_HOST` | `motto.stage.dafalabs.com` | `motto.dafalabs.com` |

Adding a required reviewer to `production` there is what turns promotion into a
decision rather than a button.

## 6. The image has to be pullable

After the first release, set the `motto` package's visibility to public under
GitHub → Packages. Packages start private even when their repository is public,
and a private one means the server needs its own registry credential — a second
standing secret for no benefit, since the image contains nothing the public
repository does not already show.

## Order

1. Steps 1–5, then merge.
2. The first merge builds the native image and pushes it. Deploy is skipped
   while `DEPLOY_ENABLED` is unset — that first run is where the native build
   gets proven.
3. Make the package public, set `DEPLOY_ENABLED=true`, and re-run the release
   workflow. That deploy is the first one that touches the server.
4. Promote to production by running **motto promote** with the digest the
   release run printed.
