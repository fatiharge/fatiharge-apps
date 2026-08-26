import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';

part 'dashboard_state.freezed.dart';

/// freezed emits a `sealed` class, so `switch` over the variants stays
/// exhaustive while equality and `copyWith` come generated. Hand-writing the
/// comparison is what this avoids: Cubit skips `emit` when the new state
/// equals the old one, so a field left out of `==` is a screen that silently
/// stops updating.
@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.loading() = DashboardLoading;

  const factory DashboardState.ready({
    required MonthPeriod period,

    required Currency currency,

    required List<Currency> availableCurrencies,
    required MonthlySummary summary,

    required List<BudgetStatus> budgetStatuses,

    required Map<String, Category> categories,

    /// False once the shown month has caught up with the current one.
    @Default(false) bool canShowNextMonth,
  }) = DashboardReady;

  const DashboardState._();
}

extension DashboardReadyX on DashboardReady {
  List<BudgetStatus> get exceededBudgets =>
      budgetStatuses.where((status) => status.isExceeded).toList();

  bool get hasData => !summary.isEmpty;
}
