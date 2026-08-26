import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// Reads are a [Stream] rather than a [Future] so that adding a transaction
/// updates the history list, the dashboard totals and the budget warnings on
/// its own — no screen has to know it should refresh another screen.
///
/// The implementation lives in `app/infrastructure/` — the domain never learns
/// that Hive exists.
abstract interface class TransactionRepository {
  Stream<List<MoneyTransaction>> watchAll();

  Future<List<MoneyTransaction>> fetchAll();

  Future<void> save(MoneyTransaction transaction);

  Future<void> delete(String id);
}
