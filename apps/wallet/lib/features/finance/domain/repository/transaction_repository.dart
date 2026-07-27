import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// Storage contract for transactions.
///
/// Reads are a [Stream] rather than a [Future] so that adding a transaction
/// updates the history list, the dashboard totals and the budget warnings on
/// its own — no screen has to know it should refresh another screen.
///
/// The implementation lives in `app/infrastructure/` — the domain never learns
/// that Hive exists.
abstract interface class TransactionRepository {
  /// Every stored transaction, re-emitted whenever the set changes.
  Stream<List<MoneyTransaction>> watchAll();

  /// A one-off read, for callers that do not want a subscription.
  Future<List<MoneyTransaction>> fetchAll();

  /// Inserts or replaces [transaction], keyed by its id.
  Future<void> save(MoneyTransaction transaction);

  Future<void> delete(String id);
}
