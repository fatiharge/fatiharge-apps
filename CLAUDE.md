# Working in this repository

A Flutter monorepo (Melos 8 + FVM) with a Quarkus backend beside it. Two apps
live here: **Warizo** (`apps/wallet`, shipped) and **Motto** (in progress).

## The authority is `architecture/`

Read it before designing anything; it is the reasoning, not a summary.
[`backend.md`](architecture/backend.md) in particular — Quarkus, Maven
multi-module under `services/`, code-first OpenAPI, promotion by digest. When
reality contradicts it, correct the document in its own commit rather than
letting the two drift.

## Branch, commit, pull request

`scripts/gitp.py` is the path, not a convenience:

```bash
scripts/gitp.py branch feature/what-it-is
scripts/gitp.py commit -m "feat(scope): what changed" path/
scripts/gitp.py pr -m "feat(scope): what the PR delivers" --wp 260
scripts/gitp.py pr        # again, to add later commits to the same PR
```

- Conventional Commits, enforced by a hook locally and on the PR title in CI.
- **A PR touching more than one workspace member drops the scope.** We squash,
  so the title becomes every touched package's changelog line.
- `--wp` links the OpenProject work package; the integration keys off that URL
  in the body and cannot pick it up afterwards.
- `main` takes squash merges only, and merging deploys motto to stage.

## Verify locally, always

Heavy CI jobs are paused on pull requests until **2026-09-06**, so what runs
before a branch is pushed is the only gate:

```bash
cd services && ./mvnw -B verify          # TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock on Colima
./scripts/generate_api_clients.sh        # after any endpoint or DTO change
fvm flutter analyze <package>            # where Dart changed
```

Merges to main still run everything, which is what stands between a broken
commit and the stage deploy.

## The contract

Resources are the source. The schema is emitted at build time into
`contracts/<service>.v1.json`, committed, and the Dart client in
`packages/api_client_<service>` is generated from it — all by the one script
above. Never hand-edit a generated client. Every endpoint declares
`@Operation(operationId = …)`, resources return DTOs, `/v1` is never mutated.

## Words

Everything a user reads lives in `content/`, and
[`content/README.md`](content/README.md) is its rulebook: the voice, the rule
that every description names a cost, and the App Review 1.4.1 word table. What
does **not** live there is anything that decides a result — scoring rules sit
with the service, so editing a sentence cannot change who gets which archetype.

## Motto

Planned in OpenProject **project 7** (`op.dafatek.com`), token at
`~/.config/openproject-token`. Each technical heading is one PR and each child
task is one commit, written as the literal commit message. **No dates anywhere**
— order lives in the heading numbers.

Keep it current as work lands. It is the only durable record of why things are
the way they are, and it drifts the moment nobody updates it.

MVP is deliberately free: accounts, purchases, invites, archive, deep report and
the mascot are all deferred to v1.1 (see the decision record, work package 369).
The one thing MVP has to measure is whether the result card gets shared.

## House habits

- Comments explain the non-obvious *why*. Leaner than the surrounding code, not
  denser.
- `packages/` kits are shared and off-limits to app work — ask before editing
  one to unblock an app.
- Port from `app_a` only what is provably used there; it has dead code.
- The commit author is the user. Do not add a Claude signature.
