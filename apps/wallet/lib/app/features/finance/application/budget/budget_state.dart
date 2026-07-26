import 'package:flutter/foundation.dart' show immutable, listEquals, mapEquals;
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';

/// The budget screen: every budget with this month's spending against it.
@immutable
class BudgetState {
  const BudgetState({
    required this.period,
    this.currency = Currency.turkishLira,
    this.statuses = const [],
    this.categories = const {},
    this.loading = true,
  });

  BudgetState.initial() : this(period: MonthPeriod.of(DateTime.now()));

  final MonthPeriod period;
  final Currency currency;

  /// Most-at-risk first.
  final List<BudgetStatus> statuses;

  final Map<String, Category> categories;
  final bool loading;

  bool get isEmpty => statuses.isEmpty;

  /// Category ids that already have a budget in [currency] — the picker hides
  /// these so one category cannot get two competing limits.
  Set<String> get budgetedCategoryIds => {
    for (final status in statuses)
      if (status.budget.categoryId != null) status.budget.categoryId!,
  };

  bool get hasOverallBudget =>
      statuses.any((status) => status.budget.isOverall);

  BudgetState copyWith({
    MonthPeriod? period,
    Currency? currency,
    List<BudgetStatus>? statuses,
    Map<String, Category>? categories,
    bool? loading,
  }) => BudgetState(
    period: period ?? this.period,
    currency: currency ?? this.currency,
    statuses: statuses ?? this.statuses,
    categories: categories ?? this.categories,
    loading: loading ?? this.loading,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetState &&
          other.period == period &&
          other.currency == currency &&
          listEquals(other.statuses, statuses) &&
          mapEquals(other.categories, categories) &&
          other.loading == loading;

  @override
  int get hashCode => Object.hash(
    period,
    currency,
    Object.hashAll(statuses),
    Object.hashAllUnordered(
      categories.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    loading,
  );
}
