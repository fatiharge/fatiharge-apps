import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';

part 'dashboard_state.freezed.dart';

/// State of the dashboard.
///
/// freezed emits a `sealed` class, so `switch` over the variants stays
/// exhaustive while equality and `copyWith` come generated. Hand-writing the
/// comparison is what this avoids: Cubit skips `emit` when the new state
/// equals the old one, so a field left out of `==` is a screen that silently
/// stops updating.
@freezed
sealed class DashboardState with _$DashboardState {
  /// Before the first data arrives from storage.
  const factory DashboardState.loading() = DashboardLoading;

  /// Everything the dashboard draws, recomputed on every underlying change.
  const factory DashboardState.ready({
    required MonthPeriod period,

    /// The currency being displayed. Totals are never mixed across currencies.
    required Currency currency,

    /// Currencies the user has actually recorded something in.
    required List<Currency> availableCurrencies,
    required MonthlySummary summary,

    /// Most-at-risk budget first.
    required List<BudgetStatus> budgetStatuses,

    /// Category lookup by id, archived ones included.
    required Map<String, Category> categories,
  }) = DashboardReady;

  const DashboardState._();
}

/// Derived values that only make sense once the data is there.
extension DashboardReadyX on DashboardReady {
  List<BudgetStatus> get exceededBudgets =>
      budgetStatuses.where((status) => status.isExceeded).toList();

  bool get hasData => !summary.isEmpty;
}
