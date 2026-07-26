import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/rules/transaction_filter.dart';

/// Events the history screen raises.
sealed class HistoryEvent {
  const HistoryEvent();
}

/// Subscribe to storage.
class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

/// The user changed the filter.
class HistoryFilterChanged extends HistoryEvent {
  const HistoryFilterChanged(this.filter);

  final TransactionFilter filter;
}

class HistoryFilterCleared extends HistoryEvent {
  const HistoryFilterCleared();
}

/// Swipe-to-delete.
class HistoryTransactionDeleted extends HistoryEvent {
  const HistoryTransactionDeleted(this.transaction);

  final MoneyTransaction transaction;
}

/// "Undo" on the delete snackbar.
class HistoryDeleteUndone extends HistoryEvent {
  const HistoryDeleteUndone(this.transaction);

  final MoneyTransaction transaction;
}

/// Internal: storage pushed new data.
class HistoryDataReceived extends HistoryEvent {
  const HistoryDataReceived({this.transactions, this.categories});

  final List<MoneyTransaction>? transactions;
  final List<Category>? categories;
}
