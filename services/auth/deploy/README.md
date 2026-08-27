# Deploying auth

Mirrors [motto's deployment](../../motto/deploy/README.md) — same reusable
workflow, same promotion by digest, same server. Only what differs is written
here.

## This service holds the private key

It is the only one that has one. Everything else verifies against the public
half and never asks auth anything, which is why a login is the only request that
reaches it.

Generate the pair once, per environment, and keep both halves out of the
repository:

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out auth-private.pem
openssl rsa -in auth-private.pem -pubout -out auth-public.pem
```

`.env` values want the PEM on one line, newlines escaped:

```bash
awk 'BEGIN{ORS="\\n"} {print}' auth-private.pem
```

**Quote it.** Compose expands `\n` back into a newline only inside double
quotes; unquoted, the two characters reach the container literally, base64
decoding fails and the service starts refusing every token as if the key were
wrong.

## `/srv/auth-stage/.env`

```dotenv
AUTH_ENV=stage
AUTH_HOST=authstage.dafalabs.com
AUTH_IMAGE=
AUTH_DB_PASSWORD=<openssl rand -base64 24>
AUTH_JWT_PRIVATE_KEY="<the private PEM, one line>"
AUTH_JWT_PUBLIC_KEY="<the public PEM, one line>"
```

## The other half goes to motto

`MOTTO_JWT_PUBLIC_KEY` in `/srv/motto-stage/.env` takes the **public** key from
the same pair. The two files have to agree: a token signed by one key and
verified against another fails in a way that looks like a broken login rather
than a configuration mistake.

Production uses a **different pair**. A stage key that can mint production
tokens makes stage a way into production.

## DNS

`authstage.dafalabs.com` and `auth.dafalabs.com`, both A records to the server,
both one label deep so the wildcard certificate covers them.

## GitHub

The deploy secrets are shared with motto and already exist. What is new is one
environment variable per environment:

| Variable | `stage` | `production` |
|---|---|---|
| `DEPLOY_PATH` | `/srv/auth-stage` | `/srv/auth-prod` |
| `SERVICE_HOST` | `authstage.dafalabs.com` | `auth.dafalabs.com` |

Those names collide with motto's: one GitHub environment cannot hold two values
for the same variable. So auth gets its own environments — `auth-stage` and
`auth-production` — and its workflows point at those.
