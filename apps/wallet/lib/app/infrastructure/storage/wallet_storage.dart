import 'package:hive_ce_flutter/hive_flutter.dart';

/// Raw Hive record: what actually lands on disk.
typedef HiveRecord = Map<dynamic, dynamic>;

/// The app's opened Hive boxes.
///
/// One object rather than three separately-registered `Box` instances: get_it
/// resolves by type, and three boxes of the same type would need named
/// registrations for no benefit.
///
/// Records are plain maps instead of generated `TypeAdapter`s. With three
/// small collections, an explicit map keeps the persisted shape reviewable in
/// one place (`*_dto.dart`) and removes a code generator from the loop; the
/// mappers are covered by round-trip tests.
class WalletStorage {
  const WalletStorage({
    required this.transactions,
    required this.categories,
    required this.budgets,
  });

  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';

  /// Opens every box. Call after `Hive.initFlutter()`.
  static Future<WalletStorage> open() async => WalletStorage(
    transactions: await Hive.openBox<HiveRecord>(transactionsBox),
    categories: await Hive.openBox<HiveRecord>(categoriesBox),
    budgets: await Hive.openBox<HiveRecord>(budgetsBox),
  );

  final Box<HiveRecord> transactions;
  final Box<HiveRecord> categories;
  final Box<HiveRecord> budgets;

  Future<void> close() => Hive.close();
}
