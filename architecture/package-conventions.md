# Package Conventions

> 🇹🇷 Türkçe için: [package-conventions.tr.md](package-conventions.tr.md)

How to build a package in this monorepo. When adding one, copy the closest existing package rather than starting from scratch.

## Every package

- Lives under `packages/<name>/` (apps under `apps/<name>/`).
- Is a Melos workspace member: its `pubspec.yaml` sets `resolution: workspace`, and `<name>` is added to the root `pubspec.yaml` `workspace:` list.
- Uses `very_good_analysis` via a one-line `analysis_options.yaml`:
  ```yaml
  include: package:lint_kit/analysis_options.yaml
  ```
- Internals live in `lib/src/`; the public API is re-exported from a single **barrel** `lib/<name>.dart`. Nothing outside the package imports `src/` directly.

```
packages/<name>/
├─ pubspec.yaml            # resolution: workspace
├─ analysis_options.yaml   # include: package:lint_kit/analysis_options.yaml
├─ lib/
│  ├─ <name>.dart          # barrel — the only public entry point
│  └─ src/                 # everything else (private by convention)
└─ test/                   # mirrors lib/src/
```

### Barrel example

```dart
// lib/ui_kit.dart
library ui_kit;

export 'src/atoms/app_button.dart';
export 'src/theme/app_theme.dart';
// ...only what consumers should see.
```

## Feature / domain package

A feature package carries the full clean-architecture stack. Group `application/` by sub-feature (use-case), not by type.

```
packages/auth/lib/src/
├─ domain/
│  ├─ models/           # freezed entities & value objects
│  ├─ repository/       # abstract repository contracts
│  ├─ ports/            # interfaces to the outside world (adapters implement these)
│  └─ rules/           # pure business rules
├─ application/
│  ├─ login/            # cubit/bloc + state for one use-case
│  ├─ register/
│  └─ forgot_password/
└─ presentation/
   ├─ page/             # screens (auto_route targets)
   ├─ router/           # this feature's auto_route module
   ├─ views/            # composed widgets
   └─ validators/       # form validators
```

Dependency rule inside the package: `presentation → application → domain`. `domain` imports nothing Flutter-specific.

## Kit packages

**`ui_kit`** — Atomic Design:

```
packages/ui_kit/lib/src/
├─ atoms/         # smallest widgets (button, text, icon)
├─ molecules/     # small compositions
├─ organisms/     # larger composed sections
├─ template/      # page-level scaffolding
├─ theme/         # color schemes + text theme
├─ core/          # shared widget infrastructure
├─ constant/
├─ extensions/
└─ side_effect/   # toasts, dialogs, haptics
```

**`utility_kit`** — framework-agnostic, **dependency-light** helpers. Keep it minimal: add code only when a real consumer needs it, and keep heavy dependencies out — UI/layout helpers belong in `ui_kit`, secure storage/crypto in a `storage_kit`, localization loaders in their own l10n package.

```
packages/utility_kit/lib/src/
└─ base/          # UI-independent base contracts (e.g. EffectBloc)
```

**`lint_kit`** — ships the shared analyzer config at `lib/analysis_options.yaml` (based on `very_good_analysis`). It is a `dev_dependency`, referenced by every other package's `analysis_options.yaml`.

## App (composition root)

The app is thin: it wires adapters to ports and hosts feature entry points.

```
apps/<app>/lib/
├─ main.dart
└─ app/
   ├─ app.dart
   ├─ config/
   │  ├─ injectable.dart / injectable.config.dart   # get_it + injectable
   │  ├─ modules/            # DI modules (api_module, core_module, environments)
   │  ├─ env.dart
   │  ├─ app_log.dart
   │  └─ app_crash_listener.dart
   ├─ infrastructure/        # THE outer edge — implements domain ports/repositories
   │  ├─ adapter/            # port adapters
   │  ├─ repository/         # *_repository_impl.dart
   │  ├─ mocks/              # API mocks for dev/test flavors
   │  └─ push/               # push notification service
   ├─ network/               # interceptor http client
   ├─ remote_config/         # accessors / mappers / models
   ├─ route/                 # app_router aggregates feature routers
   ├─ theme/                 # app-level theme wiring (uses ui_kit)
   └─ features/<f>/presentation/{page,router}   # thin feature shells
```

Key point: **only the app knows concrete adapters.** Feature/domain packages declare ports; `app/infrastructure/` implements them and DI (`config/modules/`) binds implementation → interface.

## Naming

- Package names: `snake_case`, matching the directory (`ui_kit`, `utility_kit`, `content_engine`).
- Kits end in `_kit`. Feature packages are named after the feature (`auth`, `dynamic_form`).
- Dart files: `snake_case.dart`. Classes: `PascalCase`. One primary public type per file.

## Testing

- Tests live in `test/`, mirroring `lib/src/` structure.
- Prefer testing `domain` and `application` (pure, fast) heavily; widget-test `presentation` where it earns its keep.
- `melos run test` runs every package that has a `test/` directory.

## Documentation

Keep hand-written docs at the level that changes slowly; let everything else be generated. This is the whole anti-drift strategy — do not hand-maintain what a tool already produces.

- **Package `README.md` (+ `README.tr.md`)** — thin and **stable**: what the package is, one short usage example, links to `CHANGELOG.md` and `architecture/`. It is *not* a changelog; touch it only when the public API changes. Bilingual like the rest of the repo: ship the `.md` / `.tr.md` pair with the cross-link header at the top. Keeping it thin is what keeps the two files cheap to maintain.
- **`CHANGELOG.md`** — generated by `melos version` from Conventional Commits. **Never hand-edit.** Your commits are the change history.
- **API reference** — comes from `///` doc comments in `lib/src/**`, rendered with `dart doc`. Document public types and members; the comment lives next to the code, so it can't drift.
- **Root README** — does not list packages; it points to `packages/`. The directory is the index, so there is nothing to keep in sync.

## When to create a new package

Create a package when code is **reused across features/apps**, needs an **independent lifecycle/versioning**, or benefits from an **enforced boundary** (you want the compiler to stop feature A from reaching into feature B's internals). Otherwise, a folder inside an existing package is enough — don't over-fragment.

## Checklist for a new package

1. `packages/<name>/` with `pubspec.yaml` (`resolution: workspace`), barrel `lib/<name>.dart`, one-line `analysis_options.yaml`, and a thin `README.md` + `README.tr.md`.
2. Add `<name>` to the root `pubspec.yaml` `workspace:` list.
3. `melos bootstrap`, then `melos run analyze` and `melos run test`.
4. Commit on a `feature/*` or `chore/*` branch with a Conventional Commit.
