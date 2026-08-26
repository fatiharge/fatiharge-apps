import 'package:hive_ce_flutter/hive_flutter.dart';

typedef HiveRecord = Map<dynamic, dynamic>;

/// One object, not three `Box` registrations: get_it resolves by type, and
/// three boxes of one type would need names for no benefit.
///
/// Plain maps instead of generated `TypeAdapter`s, so the persisted shape
/// stays reviewable in `*_dto.dart` and there is one less generator.
class WalletStorage {
  const WalletStorage({
    required this.transactions,
    required this.categories,
    required this.budgets,
  });

  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';

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
