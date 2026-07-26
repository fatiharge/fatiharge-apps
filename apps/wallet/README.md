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
```

## Layout

```
lib/app/
├─ features/finance/     domain / application / presentation
├─ features/startup/     the bootstrap screen
├─ infrastructure/       Hive adapters — the only code that knows the storage
├─ config/  route/  theme/
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
