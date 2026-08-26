# wallet

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

A local-first personal income/expense tracker. No backend: everything lives in
Hive on the device.

## Running

```bash
fvm install                 # once, reads .fvmrc
fvm flutter pub get         # from the repo root (pub workspace)
cd apps/wallet
fvm dart run build_runner build   # freezed / auto_route / injectable
fvm flutter run
```

Useful flags:

```bash
fvm flutter run --dart-define=SEED_DEMO_DATA=true   # fill an empty database
fvm flutter run --dart-define=FEATURE_DEBUG_LOGS=false

# Both growth features are built to wait — a fortnight before the review ask,
# a month between reminders. This collapses that waiting so they can be seen
# in one sitting. Debug builds only; the define is ignored in release.
fvm flutter run --dart-define=DEBUG_GROWTH=true --dart-define=SEED_DEMO_DATA=true
```

With `DEBUG_GROWTH` on, the review dialog appears as soon as a month with
numbers in it is on the dashboard, and turning the monthly reminder on
posts the notification straight away instead of scheduling it for the chosen
day — an inexact alarm cannot be aimed at the next minute on Android, and a
reinstall cancels pending alarms anyway. What the flag does *not* do is fake
the moment itself: an empty month still asks for nothing.

On Android the review dialog needs the app to have come from Play, so it shows
nothing on a sideloaded build — the iOS simulator is where to look.


## Translations

UI strings are addressed through generated constants
(`LocaleKeys.dashboard_income.tr()`), never raw strings — a typo in a raw key
is invisible until it renders on screen. After editing anything under
`assets/translations/`:

```bash
melos run generate:l10n     # from the repo root
```

This is **not** part of `melos run generate`: easy_localization ships a
standalone executable rather than a `build_runner` builder. The script also
formats the output, which is required — the generator emits code that
`dart format --set-exit-if-changed` rejects.

One sharp edge: the generator treats any key whose last segment is a plural
form name (`zero`, `one`, `two`, `few`, `many`, `other`) as part of a plural
group and emits no constant for it. That is why the "other" category is keyed
`category.misc`. `test/app/l10n/translations_test.dart` fails the build if a
key loses its constant, or if `tr` and `en` drift apart.

## Layout

```
lib/
├─ main.dart · app.dart  entry point and root widget
├─ features/finance/     domain / application / presentation
├─ features/startup/     the bootstrap screen
├─ infrastructure/       Hive adapters — the only code that knows the storage
├─ config/  route/  theme/
└─ generated/            localization keys
```

The feature lives inside the app rather than in `packages/`: it has a single
consumer, so there is nothing to share yet (see
[architecture/package-conventions.md](../../architecture/package-conventions.md)).
`domain/` stays free of Flutter, Hive and IO imports, which is what keeps
extracting it later cheap.

## Design notes

- **Money is stored in minor units** (`int` kuruş/cents), never `double`.
  User input is parsed by `Money.tryParse`, which never constructs a double.
- **Multi-currency without exchange rates.** Totals are scoped to one currency
  at a time and the dashboard offers a switcher; sums are never mixed.
- **Repositories return streams**, so adding a transaction updates the
  dashboard, the history list and the budget warnings on its own.
- **Categories are archived, never deleted** — past transactions reference
  them by id and must keep resolving.

## Not in v1

Flavors, backend sync, recurring transactions, export, push notifications.
Budget alerts are in-app only.
