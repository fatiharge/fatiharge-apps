# bootstrap

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

App startup orchestration for the Fatiharge monorepo: a guarded crash boundary
and a retryable startup-job engine. The presentation (splash view, routing)
stays in the app and is supplied through `BootstrapPort`.

Import the barrel; do not reach into `src/`:

```dart
import 'package:bootstrap_kit/bootstrap_kit.dart';
```

## What's inside

### `CrashListener`

The outermost startup boundary: runs the app inside a guarded zone and forwards
framework + uncaught async errors to `onCrash`. Implement `onCrash` in the app
(e.g. report to Crashlytics).

```dart
class AppCrashListener extends CrashListener {
  @override
  Future<void> onCrash({required Object error, StackTrace? stack, required bool fatal}) async {
    // report to your crash backend
  }
}

void main() => AppCrashListener().runGuarded(() async {
  // configureDependencies(); runApp(...);
});
```

### `BootstrapCubit` + `BootstrapPort` + `BootstrapJob`

Runs ordered startup jobs, each with its own retries, error policy
(`skip` / `retry` / `restart`) and optional `fallback`, emitting progress and
stopping on a failure that can be resumed. The app implements `BootstrapPort`.

```dart
class AppBootstrapPort extends BootstrapPort {
  @override
  List<BootstrapJob> jobs() => [
        BootstrapJob('remote-config', fetchRemoteConfig, retries: 2),
        BootstrapJob('warm-cache', warmCache, errorPolicy: BootstrapErrorPolicy.skip),
      ];

  @override
  Widget get bootstrapView => const SplashPage();

  @override
  void bootstrapFinished() => router.replaceAll([const HomeRoute()]);
}
```

## Documentation

- API reference: doc comments in `lib/src/**` (render with `dart doc`).
- Change history: [`CHANGELOG.md`](CHANGELOG.md) — generated from Conventional
  Commits by `melos version`; do not edit by hand.
- Design rationale: see [`architecture/`](../../architecture) at the repo root.
