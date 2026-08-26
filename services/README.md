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

## Layout

```
services/
├─ pom.xml     parent: Quarkus BOM, plugin versions, Jandex
└─ core/       library module — compiled into every service, never called over the network
```

One runnable module per app arrives with the first service. Services do not talk
to each other at runtime: `auth` issues a JWT and each service verifies it
locally against the public key.

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

Native builds and `@QuarkusIntegrationTest` belong on merge rather than on a
pull request, and arrive with the first deployable service.
