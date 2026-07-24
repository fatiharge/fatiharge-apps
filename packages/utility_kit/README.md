# utility_kit

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

Framework-level, UI-independent utilities shared across the Fatiharge monorepo.
Keep this package **dependency-light** — UI, storage, crypto and localization
helpers belong in their own kits.

Import the barrel; do not reach into `src/`:

```dart
import 'package:utility_kit/utility_kit.dart';
```

## What's inside

### `EffectBloc<Event, State, Effect>`

A `Bloc` that emits one-shot side effects (navigation, snackbar, toast, …) on a
separate channel from its state stream. State describes *what to render*; an
effect describes *something to do once*.

```dart
class LoginBloc extends EffectBloc<LoginEvent, LoginState, LoginEffect> {
  LoginBloc() : super(const LoginState.initial()) {
    on<Submitted>((event, emit) async {
      // ... on success:
      emitEffect(const LoginEffect.navigateHome());
    });
  }
}

// In the presentation layer, listen to `bloc.effects` for one-shot handling.
```

## Documentation

- API reference: doc comments in `lib/src/**` (render with `dart doc`).
- Change history: [`CHANGELOG.md`](CHANGELOG.md) — generated from Conventional
  Commits by `melos version`; do not edit by hand.
- Design rationale: see [`architecture/`](../../architecture) at the repo root.
