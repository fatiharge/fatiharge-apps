# Testing

> 🇹🇷 Türkçe için: [testing.tr.md](testing.tr.md)

How we test in this monorepo. The layering in [overview.md](overview.md) exists largely to make testing cheap: pure `domain` and `application` code needs no Flutter or IO.

## What to test where

| Layer            | Test type                | Aim for                                    |
| ---------------- | ------------------------ | ------------------------------------------ |
| `domain`         | Pure unit tests          | High coverage — rules, models, mappers     |
| `application`    | Cubit/bloc tests         | Every state transition & side effect       |
| `presentation`   | Widget tests             | Key screens, critical widgets, golden-worthy UI |
| adapters (app)   | Integration/contract     | Port implementations against fakes/mocks   |

Push logic **down** into `domain`/`application` so most tests are fast pure-Dart tests. Widget tests are valuable but slower — spend them where they earn their keep.

## Tooling

| Purpose            | Package                                   |
| ------------------ | ----------------------------------------- |
| Test runner        | `flutter_test`                            |
| Bloc/cubit tests   | `bloc_test`                               |
| Mocks / fakes      | `mocktail` (no codegen, null-safe)        |
| Matchers           | built-in + `flutter_test` matchers        |

> Prefer `mocktail` over `mockito` — no build_runner step. Mock **ports/repositories** (the interfaces), never concrete adapters.

## Layout

Tests live in each package's `test/`, mirroring `lib/src/`:

```
packages/auth/
├─ lib/src/application/login/login_cubit.dart
└─ test/application/login/login_cubit_test.dart
```

## Conventions

- One behavior per `test`; group by unit with `group('LoginCubit', …)`.
- Arrange–Act–Assert; name tests by expected behavior ("emits [loading, success] when …").
- For cubits/blocs use `blocTest` with explicit `build`, `act`, `expect`.
- Fakes implement domain **ports**; keep them in `test/` (or a shared `test/fakes/`).
- No network, no real storage, no `DateTime.now()` in tests — inject clocks/ports.

### Example — cubit test

```dart
void main() {
  late LoginRepository repository; // a domain port

  setUp(() => repository = _MockLoginRepository());

  blocTest<LoginCubit, LoginState>(
    'emits [loading, success] when credentials are valid',
    build: () {
      when(() => repository.login(any(), any()))
          .thenAnswer((_) async => const Session(token: 't'));
      return LoginCubit(repository);
    },
    act: (cubit) => cubit.submit('a@b.c', 'pw'),
    expect: () => const [LoginState.loading(), LoginState.success()],
  );
}

class _MockLoginRepository extends Mock implements LoginRepository {}
```

## Running

```bash
melos run test        # every package that has a test/ dir
melos run coverage    # same, with --coverage (writes coverage/lcov.info per package)
```

CI runs `melos run test` on every PR (see `.github/workflows/ci.yml`). A change that alters behavior should ship with tests.

## Coverage

- Generate locally with `melos run coverage`; merge/inspect `coverage/lcov.info`.
- `flutter test --coverage` only instruments libraries the tests import, so a
  file with no test is **absent** from the report rather than reported as 0% —
  which silently inflates the percentage. `test/coverage_helper_test.dart`
  imports every library to prevent that; regenerate it with
  `melos run coverage:helper`. It fails the build when a new library is missing
  from it, so the number cannot drift back into being flattering.
- Read the report with `genhtml coverage/lcov.info -o coverage/html` (needs
  `brew install lcov`), or an editor extension that renders `lcov.info` inline.
- Aim high on `domain`/`application`; don't chase 100% on generated or presentation glue.
- Exclude generated files (already excluded from analysis via `lint_kit`).
