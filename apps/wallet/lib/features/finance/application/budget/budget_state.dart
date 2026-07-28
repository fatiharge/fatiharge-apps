import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';

part 'budget_state.freezed.dart';

/// The budget screen: every budget with this month's spending against it.
@freezed
abstract class BudgetState with _$BudgetState {
  const factory BudgetState({
    required MonthPeriod period,
    @Default(Currency.turkishLira) Currency currency,

    /// Most-at-risk first.
    @Default(<BudgetStatus>[]) List<BudgetStatus> statuses,
    @Default(<String, Category>{}) Map<String, Category> categories,
    @Default(true) bool loading,
  }) = _BudgetState;

  const BudgetState._();

  /// The screen before storage has answered.
  factory BudgetState.initial({DateTime? now}) =>
      BudgetState(period: MonthPeriod.of(now ?? DateTime.now()));

  bool get isEmpty => statuses.isEmpty;

  /// Category ids that already have a budget in [currency] — the picker hides
  /// these so one category cannot get two competing limits.
  Set<String> get budgetedCategoryIds => {
    for (final status in statuses)
      if (status.budget.categoryId != null) status.budget.categoryId!,
  };

  bool get hasOverallBudget =>
      statuses.any((status) => status.budget.isOverall);
}
