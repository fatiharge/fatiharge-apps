# Dependency Injection

> 🇹🇷 Türkçe için: [dependency-injection.tr.md](dependency-injection.tr.md)

We use **`get_it`** as the service locator and **`injectable`** to generate its registrations. DI is where the hexagonal architecture is wired: the app binds concrete **adapters** to the **ports** that feature/domain packages declare (see [overview.md](overview.md)).

## Where DI lives

Only the **app** (composition root) knows concrete implementations. Registration lives under `apps/<app>/lib/app/config/`:

```
config/
├─ injectable.dart          # configureDependencies() entry point
├─ injectable.config.dart   # GENERATED — do not edit
└─ modules/
   ├─ core_module.dart      # third-party singletons (http, storage, …)
   ├─ api_module.dart       # API client / networking wiring
   └─ environments.dart     # environment (flavor) constants
```

## How it fits the layers

- **domain** declares a `port` or repository *interface*.
- **application** depends on that interface (constructor injection), never on a concrete class.
- **app/infrastructure** provides the `*_impl` adapter and annotates it so `injectable` binds it to the interface.

```dart
// domain (in a feature package) — the contract
abstract class AuthRepository {
  Future<Session> login(String email, String password);
}

// app/infrastructure — the adapter, bound to the interface
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);
  final AuthApi _api;
  // ...
}
```

## Registration annotations

| Annotation                 | Use for                                              |
| -------------------------- | ---------------------------------------------------- |
| `@injectable`              | New instance each resolve                            |
| `@lazySingleton`           | Single instance, created on first use (default choice) |
| `@singleton`               | Single instance, created at registration             |
| `@LazySingleton(as: Port)` | Bind an implementation to its interface/port         |
| `@module`                  | Provide third-party types you don't own (in `modules/`) |

### Third-party types via a module

```dart
@module
abstract class CoreModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
```

## Entry point

```dart
// injectable.dart
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

final getIt = GetIt.instance;
```

Called once during app bootstrap, before `runApp`. Consumers resolve with `getIt<AuthRepository>()` — or, for widgets, via the bloc/cubit provided from `getIt`.

## Environments (flavors)

Use `injectable` environments to swap implementations per flavor — e.g. real API vs mock:

```dart
@LazySingleton(as: AuthApi, env: [Environment.dev])
class AuthApiMock implements AuthApi { /* ... */ }

@LazySingleton(as: AuthApi, env: [Environment.prod])
class AuthApiHttp implements AuthApi { /* ... */ }
```

Select the environment in `configureDependencies` based on the active flavor. Mocks (`app/infrastructure/mocks/`) let `dev` builds run without a live backend.

## Rules

- **Depend on interfaces, not implementations.** Constructors take ports; DI supplies adapters.
- **Only the app registers concretes.** Packages stay ignorant of `get_it`.
- **Regenerate after changing annotations:** `melos run generate` (or `dart run build_runner build --delete-conflicting-outputs`). `injectable.config.dart` is committed but never hand-edited.
