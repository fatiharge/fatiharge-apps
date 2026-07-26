import 'package:flutter/foundation.dart';
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';
import 'package:wallet/app/features/finance/domain/rules/monthly_summary.dart';

/// State of the dashboard.
///
/// A hand-written `sealed class` rather than a freezed union: Dart's exhaustive
/// `switch` already covers what `when`/`map` were invented for.
sealed class DashboardState {
  const DashboardState();
}

/// Before the first data arrives from storage.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Everything the dashboard draws, recomputed on every underlying change.
class DashboardReady extends DashboardState {
  const DashboardReady({
    required this.period,
    required this.currency,
    required this.availableCurrencies,
    required this.summary,
    required this.budgetStatuses,
    required this.categories,
  });

  final MonthPeriod period;

  /// The currency being displayed. Totals are never mixed across currencies.
  final Currency currency;

  /// Currencies the user has actually recorded something in.
  final List<Currency> availableCurrencies;

  final MonthlySummary summary;

  /// Most-at-risk budget first.
  final List<BudgetStatus> budgetStatuses;

  /// Category lookup by id, archived ones included.
  final Map<String, Category> categories;

  List<BudgetStatus> get exceededBudgets =>
      budgetStatuses.where((status) => status.isExceeded).toList();

  bool get hasData => !summary.isEmpty;

  // Deep equality, not a length check: Cubit skips `emit` when the new state
  // equals the old one, so anything this comparison misses is a screen that
  // silently fails to update.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardReady &&
          other.period == period &&
          other.currency == currency &&
          other.summary == summary &&
          listEquals(other.availableCurrencies, availableCurrencies) &&
          listEquals(other.budgetStatuses, budgetStatuses) &&
          mapEquals(other.categories, categories);

  @override
  int get hashCode => Object.hash(
    period,
    currency,
    summary,
    Object.hashAll(availableCurrencies),
    Object.hashAll(budgetStatuses),
    Object.hashAllUnordered(categories.entries.map((e) => Object.hash(e.key, e.value))),
  );
}
