import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// One-shot things the history screen should *do* (as opposed to render).
sealed class HistoryEffect {
  const HistoryEffect();
}

/// Show the undo snackbar for a just-deleted transaction.
class HistoryTransactionRemoved extends HistoryEffect {
  const HistoryTransactionRemoved(this.transaction);

  final MoneyTransaction transaction;
}

/// The delete was undone.
class HistoryDeleteRestored extends HistoryEffect {
  const HistoryDeleteRestored();
}
