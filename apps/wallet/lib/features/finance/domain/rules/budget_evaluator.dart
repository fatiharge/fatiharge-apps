import 'package:meta/meta.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';

enum BudgetHealth {
  safe,

  warning,

  exceeded,
}

@immutable
class BudgetStatus {
  const BudgetStatus({required this.budget, required this.spent});

  final Budget budget;
  final Money spent;

  Money get remaining => budget.limit - spent;

  /// Spend as a fraction of the limit. A zero limit yields `1.0` when anything
  /// was spent (a zero budget is immediately blown) and `0.0` otherwise.
  double get ratio {
    final value = spent.ratioOf(budget.limit);
    if (value != null) return value;
    return spent.isZero ? 0 : 1;
  }

  BudgetHealth get health {
    if (ratio >= 1) return BudgetHealth.exceeded;
    if (ratio >= BudgetEvaluator.warningThreshold) return BudgetHealth.warning;
    return BudgetHealth.safe;
  }

  bool get isExceeded => health == BudgetHealth.exceeded;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetStatus && other.budget == budget && other.spent == spent;

  @override
  int get hashCode => Object.hash(budget, spent);
}

/// Pure and synchronous: given the same summary it always produces the same
/// statuses, which is what makes the overspend warning cheap to test.
abstract final class BudgetEvaluator {
  /// The share of a limit at which the UI starts warning.
  static const double warningThreshold = 0.8;

  /// Results are ordered most-at-risk first so the UI can show the top
  /// offenders without re-sorting.
  static List<BudgetStatus> evaluate({
    required Iterable<Budget> budgets,
    required MonthlySummary summary,
  }) {
    final statuses =
        budgets
            .where((budget) => budget.currency == summary.currency)
            .map(
              (budget) => BudgetStatus(
                budget: budget,
                spent: budget.isOverall
                    ? summary.expense
                    : summary.spentOn(budget.categoryId!),
              ),
            )
            .toList()
          ..sort((a, b) => b.ratio.compareTo(a.ratio));
    return statuses;
  }

  static List<BudgetStatus> exceeded({
    required Iterable<Budget> budgets,
    required MonthlySummary summary,
  }) => evaluate(
    budgets: budgets,
    summary: summary,
  ).where((status) => status.isExceeded).toList();
}
