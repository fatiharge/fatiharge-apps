# services

Backend services. **Not a Dart workspace member** — Melos and pub do not see
this tree, and `melos version` cannot version it.

[architecture/backend.md](../architecture/backend.md) is the authority on why
this shape was chosen; this file is the day-to-day.

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

## Requirements

JDK 21 and a running container engine (Colima, OrbStack or Docker Desktop).
Maven comes from the wrapper — use `./mvnw`, not a locally installed `mvn`.

```bash
cd services
./mvnw -B verify
```

### Colima

Tests start a PostgreSQL container through Dev Services, and Testcontainers
needs to reach the Docker socket the way the container engine sees it. Under
Colima that is not the default, and the failure looks unrelated — *"Container
startup failed for image testcontainers/ryuk"*. Export this once:

```bash
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
```

Docker Desktop, OrbStack and the CI runners need nothing.

## Layout

```
services/
├─ pom.xml     parent: Quarkus BOM, plugin versions, Jandex
├─ core/       library module — compiled into every service, never called over the network
├─ auth/       runnable — turns a device hash into an identity and signs its token
└─ motto/      runnable — the motto app's API
```

One runnable module per app, one subdomain per module: a change to one app's API
leaves every other app's generated client untouched. A single shared schema
would regenerate every client for a field one app asked for.

One runnable module per app arrives with the first app service. Services do not
talk to each other at runtime: `auth` issues a JWT and each service verifies it
locally against the public key, so the only request that ever reaches `auth` is
a registration.

## Adding a module

1. Create the directory and add a `<module>` to `services/pom.xml`.
2. **A library module declares the Jandex plugin.** Quarkus does not discover
   CDI beans inside dependency jars without an index, so a library without it
   starts cleanly and silently has no beans. The configuration is already in the
   parent; the module only declares the plugin.
3. A runnable module declares `quarkus-maven-plugin` instead.
4. Package by feature under `com.dafalabs.api.<app>`, not by layer. A small
   feature is one file; layers appear when a feature grows into them.

## Error contract

Throw, do not catch. A resource never turns an exception into a status code:

```java
throw new CustomRuntimeException(409, "cooldown_open", "Yeni motto için beklemen gerekiyor.");
```

- `code` is stable, snake_case and machine-readable. Clients branch on it;
  messages are free to change wording.
- **A 5xx never returns its own message.** The real reason goes to the log,
  together with the `traceId` the caller receives — so a user reporting "it
  failed" gives something to search for.
- `UnhandledExceptionMapper` catches everything else, so the contract really
  covers all of it. A `WebApplicationException` that already carries a body
  passes through untouched; that branch has no unit test yet because it needs a
  running endpoint, and gets one with the first service.

## Identity

There is no account until something is bought, so a device is the identity. The
app hashes the identifier it keeps in the Keychain or in
`Settings.Secure.ANDROID_ID` and sends the hash; the raw identifier never
reaches a server, which is what makes the `devices` table dull if it ever leaks.

`POST /v1/devices/register` is idempotent by design: registering again with the
same hash returns the identity that already exists. That happens constantly,
because a token is short-lived and **there is no refresh flow** — with no
account there is no session to keep alive, so the app simply registers again.

The consequence is worth stating plainly: the device hash is the credential.
Anyone holding it can obtain a token. That is inherent to an account-free
product; rate limiting and, later, platform attestation are what harden it.

Signing keys never live in the repository except for the worthless pair in
`auth/dev-keys/` (see its README). The packaged application has no key
configured at all, so a deployment that forgets `SMALLRYE_JWT_SIGN_KEY` fails at
signing rather than falling back to something known.

## Configuration

Shared defaults live in
`core/src/main/resources/META-INF/microprofile-config.properties`. Precedence
runs bottom-up: those defaults, then a service's own `application.properties`,
then environment variables.

**No secret belongs in this repository.** Secrets arrive as environment
variables and only as environment variables.

Swagger UI is a dev-profile feature: a service may enable it under `%dev` and
never for stage or prod.

## Quarkus version

Pinned once, in the parent, as `quarkus.platform.version`. It tracks the current
release rather than an LTS branch: nothing here is legacy yet, Dependabot keeps
it moving and CI catches what a bump breaks. If the monthly bumps turn into
noise, moving to an LTS branch is that one property.

## CI

`Services CI` runs on every pull request, works out for itself whether
`services/` changed, and reports through a job named **Build & test services**.
The work is filtered by path, the gate is not — a workflow skipped by a
top-level `paths:` filter reports no status at all, and a required check that
never reports blocks the pull request forever.

> **One manual step is outstanding:** `Build & test services` is not yet listed
> in the `main-protection` ruleset, so it reports but cannot block. Add it under
> GitHub → Settings → Rules to turn it into a gate.

Native builds and `@QuarkusIntegrationTest` run on merge rather than on a pull
request, in **motto release** — a pull request wants the fast answer. That
workflow also accepts a manual run, which is how a native build gets proven from
a branch before merging; dispatched from anywhere but `main` it builds the image
and stops, because deploying a branch to stage should not be one click away.

**motto promote** moves an existing image to production by digest and never
rebuilds. What the server needs is in
[motto/deploy/README.md](motto/deploy/README.md).
