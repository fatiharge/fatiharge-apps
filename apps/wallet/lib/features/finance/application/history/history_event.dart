import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

class HistoryFilterChanged extends HistoryEvent {
  const HistoryFilterChanged(this.filter);

  final TransactionFilter filter;
}

class HistoryFilterCleared extends HistoryEvent {
  const HistoryFilterCleared();
}

class HistoryTransactionDeleted extends HistoryEvent {
  const HistoryTransactionDeleted(this.transaction);

  final MoneyTransaction transaction;
}

class HistoryDeleteUndone extends HistoryEvent {
  const HistoryDeleteUndone(this.transaction);

  final MoneyTransaction transaction;
}

class HistoryDataReceived extends HistoryEvent {
  const HistoryDataReceived({this.transactions, this.categories});

  final List<MoneyTransaction>? transactions;
  final List<Category>? categories;
}
