import 'package:wallet/features/finance/domain/models/money_transaction.dart';

sealed class HistoryEffect {
  const HistoryEffect();
}

class HistoryTransactionRemoved extends HistoryEffect {
  const HistoryTransactionRemoved(this.transaction);

  final MoneyTransaction transaction;
}

class HistoryDeleteRestored extends HistoryEffect {
  const HistoryDeleteRestored();
}
