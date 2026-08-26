import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

sealed class DashboardEvent {
  const DashboardEvent();
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

class DashboardPreviousMonthRequested extends DashboardEvent {
  const DashboardPreviousMonthRequested();
}

class DashboardNextMonthRequested extends DashboardEvent {
  const DashboardNextMonthRequested();
}

class DashboardCurrencySelected extends DashboardEvent {
  const DashboardCurrencySelected(this.currency);

  final Currency currency;
}

/// Internal: storage pushed new data. Each stream fills its own field and
/// leaves the rest null, so one arriving does not blank out the others.
class DashboardDataReceived extends DashboardEvent {
  const DashboardDataReceived({
    this.transactions,
    this.categories,
    this.budgets,
  });

  final List<MoneyTransaction>? transactions;
  final List<Category>? categories;
  final List<Budget>? budgets;
}
