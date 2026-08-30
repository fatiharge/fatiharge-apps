# App layers

> 🇹🇷 Türkçe için: [app-layers.tr.md](app-layers.tr.md)

Where a thing goes inside an app, and why. [`overview.md`](overview.md) covers
the repository; this covers one Flutter app, using `apps/motto` throughout
because it is the one with every layer in it.

## The shape

```
features/<feature>/
  domain/         pure Dart: rules, value types. No Flutter, no IO.
  application/    cubits, repositories, stores. Knows the server, not the screen.
  presentation/   pages and widgets. Knows the screen, not the server.
infrastructure/   what the whole app needs: session, api, effects, analytics.
route/            the router and what depends on it.
config/           the container, environment, crash reporting.
```

Three of those names are load-bearing and are explained below. The rest are
where you would guess.

## Store, repository, cubit

The distinction that costs people the most time, so it goes first.

A **store** is where a value lives between launches. Nothing else. It owns the
key, the serialisation and the answer to "what if it is corrupt". It never
decides anything.

A **repository** decides *where a value comes from* when there is more than one
source. `ChainRepository` has two — the server and `ChainStore` — and its whole
job is choosing between them: cache first so the screen draws immediately, the
queue when the network fails, the server's answer when it arrives.

A **cubit** is state and flow for one screen. It calls repositories; they never
call it.

So a feature has a repository only when it has something to reconcile. Four of
motto's six stores have none, and that is not an omission:

| Store | Repository | Why |
| --- | --- | --- |
| `chain_store` | yes | server cache plus an offline queue |
| `task_store` | yes | the same, for the day's three things |
| `content_store` | yes | a downloaded package, versioned by ETag |
| `effect_store` | yes | the same, for what refusals lead to |
| `token_store` | no | the Keychain, read once and held |
| `onboarding_store`, `game_store` | no | one boolean about this installation |

The last row is worth naming: those two are deliberately about the *device*
rather than the person. Somebody reinstalling has earned the introduction again
more than they have earned skipping it. A device-scoped preference may decide
things locally. A cached copy of server truth may not — the app once asked
somebody to fill in the inventory again because the preference holding their
archetype had been wiped while the server still had the result.

## What a request comes back as

Every call goes through `asked()` and comes back as an `Outcome`:

```
Outcome<T> = Ok<T> | Failed<T>(Trouble)

Trouble = Refused(code)   the server said no on purpose, and named it
        | NotAllowed      403 — a door the app should not have offered
        | SessionOver     401 that survived a renewal
        | Offline         it never arrived
        | Broken          ours; reported on the way past
```

`Trouble` is a closed hierarchy, so a `switch` over it is exhaustive: a new
kind of failure cannot be added without every screen being asked what it means.

**Only `Refused` is local.** Its name is what tells a screen whether to send
somebody to their tasks or offer a different email. Everything else means the
same thing wherever it happens, so it goes to `TroubleBus` and is answered once,
above the tabs. A screen that has nothing to say about a refusal passes it on
with `unhandled()`; what it leads to is then a row somebody edited rather than
a branch somebody shipped.

## Where the words live

Nothing a person reads is written in Dart if it can be written in a row.
`content/README.md` is the rulebook. The daily texts, the archetypes and the
mottos come down in the content package; what a refusal leads to comes down
from `/v1/effects`. Both are cached to a file, versioned by a hash, and both are
survivable when missing — one by saying so, the other by falling back to a
plain sentence.

## Rules that were learned the hard way

- **A screen that fails must be askable again.** `CouldNotLoad` carries that
  promise; six copies of it had grown before it existed.
- **Something a person pressed that did not happen has to say so.** A sheet for
  a failed action, an inline retry for a failed screen — a sheet closes onto
  the same empty screen it was explaining.
- **Nothing technical reaches a screen.** A status code is a fact about our
  server, not about anything the person holding the phone can do.
- **The mascot lives above the router.** Its callbacks run in
  `MaterialApp.builder`, which has neither a router nor a navigator, so
  anything it triggers must not take a `BuildContext`.
- **A tab is built once and kept alive.** What one tab changes for another has
  to be reloaded deliberately; `ReloadsOnReturn` covers screens closing over a
  tab, and the shell covers tab switches and coming back from the background.

## Reading order

Eight files, each picking up where the last leaves off:

```
main.dart
  → features/startup/presentation/startup_page.dart
  → infrastructure/bootstrap/bootstrap_adapter.dart      ← the rules are here
  → infrastructure/session/device_session.dart
  → features/content/application/content_repository.dart
  → features/shell/presentation/shell_page.dart
  → features/chain/application/chain_cubit.dart → chain_repository.dart
  → infrastructure/api/api_clients.dart + outcome.dart
```
