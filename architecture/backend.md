# Backend

> 🇹🇷 Türkçe için: [backend.tr.md](backend.tr.md)

The Flutter side of this repo is a Dart pub workspace. The backend is not — it
lives beside it, under `services/`, and Melos does not see it. Everything below
is the shape it takes and the reasons behind each choice.

## Why it lives here at all

One reason, and it is enough: **the OpenAPI schema and the Dart client that
consumes it change in the same commit.** A schema change and the app code that
depends on it are reviewed together, and an app that would break against the new
schema fails to compile in the same pull request. Splitting the backend into its
own repository is what makes "the backend deployed and the app broke" possible.

The costs are real and are accepted: the Dart workspace cannot contain a Java
module, `melos version` cannot version one, and CI grows a second toolchain.

## Layout

```
fatiharge-apps/
├─ apps/                       # Flutter (Dart workspace)
├─ packages/
│  └─ api_client_<app>/        # generated Dart client, never hand-edited
├─ services/                   # NOT a Dart workspace member
│  ├─ pom.xml                  # parent: Quarkus BOM, plugins, Jandex
│  ├─ core/                    # library module — user, auth, subscription
│  ├─ auth/                    # runnable — issues JWTs
│  └─ <app>/                   # runnable — one per app
├─ contracts/
│  └─ <app>.v1.json            # emitted at build, committed, gated in CI
└─ architecture/
```

## Modules

Maven multi-module. `core` is a **library**: it is compiled into every service
rather than called over the network. Services do not talk to each other at
runtime — `auth` issues a JWT and each service verifies it locally against the
public key, so the only request that reaches `auth` is a login.

One runnable module per app, one subdomain per runnable module. This is not
premature microservices: it exists so a change to one app's API leaves every
other app's client untouched. A single shared schema would regenerate fifteen
clients for a field only one app asked for.

**Jandex.** Quarkus does not discover CDI beans inside dependency jars without a
Jandex index. A library module without `jandex-maven-plugin` starts cleanly and
silently has no beans. It is configured once, in the parent pom.

## File tree

Package by feature, not by layer:

```
com/dafalabs/api/<app>/
├─ transaction/
│  ├─ TransactionResource.java
│  ├─ TransactionService.java
│  ├─ Transaction.java
│  ├─ TransactionRepository.java
│  └─ dto/
└─ budget/
```

A small feature may be one file. Layers appear when a feature grows into them,
not before. `core` follows the same shape, plus one cross-cutting package for
errors.

## Rules

- **Resources return DTOs, never entities.** An entity on the wire puts the
  database shape into the contract, where it changes whenever the table does.
- **Paths are versioned:** `/v1/…`. A breaking change opens `/v2`; `/v1` is
  never mutated and stays up until nothing calls it.
- **`@Authenticated` on the resource class**, not per method. Easy to forget one
  method; hard to forget a class.
- **One error contract.** Every exception extends `CustomRuntimeException` and
  carries its own HTTP status; a single `ExceptionMapper` renders them all.
- **No `quarkus-hibernate-orm-rest-data-panache`.** It generates CRUD endpoints,
  which contradicts a schema anyone is expected to read.
- **Flyway, never `hibernate-orm.database.generation`.** Auto-DDL cannot drop a
  column, cannot rename, cannot be reviewed and cannot be rolled back.
- **Config from environment variables.** No secret reaches the repository.
- **Swagger UI is a dev profile feature.** It does not ship to stage or prod.

## Data

One PostgreSQL, one schema per service: `core.users`, `<app>.…`. A service
writes only to its own schema. Flyway locations are per module, so each service
carries its own migrations.

The database is reachable only on the internal Docker network. It gets no
Traefik route and no published port.

**Migrations carry schema, never content.** Motto's tasks and report pieces
were briefly seeded by two generated repeatable migrations — hundreds of
committed `INSERT` lines — which put the product's words in the schema history
and made correcting a typo a release. They are pushed over `/admin/content`
now, guarded by `MOTTO_ADMIN_TOKEN`, kept out of the published schema so no
generated client learns they exist, and closed to everyone when the variable is
unset. The rule that follows: if a human wrote it and might rewrite it, it does
not belong in `db/migration`.

**A worded row belongs to one language.** Every content table is keyed by
`(…, locale)`, every read takes the language as a parameter, and the resources
resolve it from `Accept-Language` — a header kept out of the published schema
with `@Parameter(hidden = true)`, so the language is a property of the client
rather than an argument at every call site. Turkish is the fallback and the
answer to anything unrecognised.

Two things follow from that, and they are the reason it is worth a paragraph
here. A package is answered in one language *whole*: `ContentCatalog` reads the
requested language, finds it empty, and serves the fallback rather than a half
of each. And the tables that decide a *result* — `archetype_rules`, which
generation of the inventory is live — carry no locale at all; `ContentWriter`
takes them from the fallback and ignores them from any other language, so
pushing a translation cannot move who gets which archetype. That is the same
rule `content/README.md` states for the words, enforced on the write path.

## The contract

Code-first. Resources and DTOs are the source; SmallRye emits the schema at
build time; the schema is committed; the Dart client is generated from the
committed file.

```
resource + DTO
   ↓ mvn package
contracts/<app>.v1.json        committed
   ↓ openapi-generator
packages/api_client_<app>      generated, never hand-edited
```

Drift between schema and implementation is not possible while resources return
plain DTOs — the schema is derived from the very types the endpoint returns.
Two disciplines keep it that way:

- **Every endpoint declares `@Operation(operationId = "…")`.** Without it the
  generated Dart method name is derived from the Java method name, and renaming
  a method silently renames the client's API.
- **Do not override a type with `@Schema`.** Whatever the DTO says is what the
  schema says.

CI enforces two gates per schema: the committed file is up to date
(`git diff --exit-code contracts/`), and `oasdiff` fails the build when a change
breaks `/v1`.

## Environments

| | where | why |
| --- | --- | --- |
| **dev** | local, `quarkus dev` | Dev Services starts PostgreSQL in a container and live reload works. A deployed dev environment is worse than this and costs a container per service. |
| **stage** | `<app>stage.dafalabs.com` | real deploy, real database |
| **prod** | `<app>.dafalabs.com` | manual trigger |

One label deep on both, so a wildcard certificate for `*.dafalabs.com` covers
them. A `<app>.stage.dafalabs.com` would need a certificate of its own.

**An image is built once.** The image that stage runs is promoted to prod by
digest — prod never rebuilds. Rebuilding is what makes "it worked in stage"
meaningless. Images live in `ghcr.io`; the repository is public, so
`GITHUB_TOKEN` is the only credential needed.

Each environment has its own database instance.

**Deployed environments do not use profiles.** A native image bakes its
build-time configuration under the profile it was built with, so handing it a
different one at runtime is a quiet source of "it worked on stage" — and
building one image per profile would contradict the promotion above, since
production would then run a sibling of the artefact stage ran rather than that
artefact. `%dev` still exists, because dev is not deployed; stage and production
run the same image under the same profile and differ only by environment
variables, held in GitHub Environments.

## CI

Native from the start, but not on every push:

| event | what runs |
| --- | --- |
| pull request | changed services only: JVM build + `@QuarkusTest` |
| merge to `main` | changed services: native build + `@QuarkusIntegrationTest` → image → stage |
| prod | `workflow_dispatch`, promoting an existing image |

`@QuarkusIntegrationTest` is not optional once the target is native. It runs
against the compiled binary, where reflection and resource loading behave
differently; `@QuarkusTest` runs on the JVM and cannot see those failures.
Native images are built in a container, so no runner needs GraalVM installed.

**A native binary carries two assumptions about the machine it will run on, and
both default to the machine that built it.** It is linked against the builder
image's glibc, so the runtime base image has to be the matching one — the
builder is pinned for that reason and the two move together. And it targets the
build machine's instruction set, so it is built with `-march=compatibility`;
CI runners are newer than the server, and the default produced a binary
demanding AVX2. Both failures look identical from outside: the container dies at
exec, restarts forever, and the proxy answers 404 because it has nothing to
route to.

**Triggering.** One reusable workflow holds the logic; a thin caller per service
carries only its `paths` filter. A service's filter includes `services/core/**`
and `services/pom.xml` as well as its own directory — a library change must
rebuild everything that links it.

**The required-check trap.** A workflow skipped by a `paths` filter reports no
status at all, and a required check that never reports blocks the pull request
forever. So the work is conditional but the gate is not: a final job runs with
`if: always()` and fails only when something it depended on failed. That job is
what `main-protection` requires.
