# Mason bricks

Code generators for consistent scaffolding. See [Mason](https://pub.dev/packages/mason_cli).

## Setup (once)

```bash
dart pub global activate mason_cli
mason get
```

## `package` — new workspace package

```bash
mason make package -o packages
```

Prompts for a `name` (snake_case) and `description`, then generates:

```
packages/<name>/
├─ pubspec.yaml            # resolution: workspace, lint_kit dev dep
├─ analysis_options.yaml   # include: package:lint_kit/analysis_options.yaml
├─ lib/<name>.dart         # barrel
├─ lib/src/                # internals
└─ test/<name>_test.dart
```

After generating, finish wiring it up:

1. Add `<name>` to the root `pubspec.yaml` `workspace:` list.
2. `melos bootstrap`, then `melos run analyze` and `melos run test`.

> The brick scaffolds a Flutter package by default. For a pure-Dart package, drop the `flutter` dependency from the generated `pubspec.yaml`.
