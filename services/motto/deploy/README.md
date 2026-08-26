# Deploying motto

The release workflow copies `compose.yaml` next to a `.env` file on the server,
rewrites `MOTTO_IMAGE` to the digest it just built, and runs
`docker compose up -d`. Nothing else about the server is in this repository.

## One-time setup, per environment

Create a directory for the environment and put a `.env` beside it. Nothing in
that file may ever be committed.

```
/srv/motto-stage/.env
/srv/motto-prod/.env
```

```dotenv
MOTTO_ENV=stage                    # names the compose project and the Traefik router
MOTTO_PROFILE=stage                # selects the Quarkus profile
MOTTO_HOST=motto.stage.dafalabs.com
MOTTO_IMAGE=                       # rewritten by every deploy; leave empty
MOTTO_DB_PASSWORD=<generate one>
MOTTO_JWT_PUBLIC_KEY=<the auth service's public key, PEM, one line with \n>

PROXY_NETWORK=<the docker network Traefik is attached to>
TRAEFIK_ENTRYPOINT=websecure       # whatever this Traefik calls its TLS entrypoint
TRAEFIK_CERTRESOLVER=letsencrypt   # whatever this Traefik calls its resolver
```

The last three are the ones that differ between installations, which is why they
are read rather than assumed.

Point a DNS record at the server for each host before the first deploy, or
Traefik will not be able to obtain a certificate.

## What GitHub needs

Repository secrets:

| Secret | What it is |
|---|---|
| `DEPLOY_HOST` | the server |
| `DEPLOY_USER` | a user that may only touch the compose directories — not root |
| `DEPLOY_SSH_KEY` | that user's private key |
| `DEPLOY_KNOWN_HOSTS` | output of `ssh-keyscan <host>`, so CI is not trusting whatever answers |

Repository variable:

| Variable | What it does |
|---|---|
| `DEPLOY_ENABLED` | Set it to `true` when the server is ready. Until then every merge builds and pushes the image and stops, instead of failing at a deploy that cannot work yet. |

Per-environment variables, under GitHub → Settings → Environments (`stage` and
`prod`):

| Variable | Example |
|---|---|
| `DEPLOY_PATH` | `/srv/motto-stage` |
| `SERVICE_HOST` | `motto.stage.dafalabs.com` |

Making `prod` a protected environment there is what turns promotion into a
decision rather than a button.

## The image has to be pullable

After the first release, set the `motto` package's visibility to public under
GitHub → Packages. Packages start private even when their repository is public,
and a private one means the server needs its own registry credential — a second
standing secret for no benefit, since the image contains nothing the public
repository does not already show.

## Promoting

The release run prints the digest it pushed. Run **motto promote** and paste it.
Nothing is rebuilt: production is handed the artefact stage has been running.

## Why the image is a digest

Stage runs an image; production runs *that* image, promoted by digest and never
rebuilt. A rebuild produces a different artefact from the same source — a
different base layer, a different compiler patch — and that is what makes "it
worked in stage" stop meaning anything.
