import 'package:meta/meta.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';

/// One slice of the category breakdown.
@immutable
class CategoryTotal {
  const CategoryTotal(this.categoryId, this.total);

  final String categoryId;
  final Money total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTotal &&
          other.categoryId == categoryId &&
          other.total == total;

  @override
  int get hashCode => Object.hash(categoryId, total);

  @override
  String toString() => 'CategoryTotal($categoryId, $total)';
}

/// Income, expense and the per-category breakdown for one month in one
/// currency.
///
/// Scoped to a single [currency] on purpose. Summing across currencies would
/// require exchange rates, which the app does not have; the dashboard instead
/// shows one currency at a time and lets the user switch.
class MonthlySummary {
  MonthlySummary._({
    required this.period,
    required this.currency,
    required this.income,
    required this.expense,
    required Map<String, Money> expenseByCategory,
    required Map<String, Money> incomeByCategory,
  }) : expenseByCategory = Map<String, Money>.unmodifiable(expenseByCategory),
       incomeByCategory = Map<String, Money>.unmodifiable(incomeByCategory);

  /// Aggregates [transactions], ignoring anything outside [period] or in a
  /// different currency.
  factory MonthlySummary.from({
    required Iterable<MoneyTransaction> transactions,
    required MonthPeriod period,
    required Currency currency,
  }) {
    final zero = Money.zero(currency);
    var income = zero;
    var expense = zero;
    final expenseByCategory = <String, Money>{};
    final incomeByCategory = <String, Money>{};

    for (final transaction in transactions) {
      if (transaction.currency != currency) continue;
      if (!period.contains(transaction.date)) continue;

      final bucket = transaction.isExpense
          ? expenseByCategory
          : incomeByCategory;
      bucket[transaction.categoryId] =
          (bucket[transaction.categoryId] ?? zero) + transaction.amount;

      if (transaction.isExpense) {
        expense += transaction.amount;
      } else {
        income += transaction.amount;
      }
    }

    return MonthlySummary._(
      period: period,
      currency: currency,
      income: income,
      expense: expense,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
    );
  }

  /// An all-zero summary, used before any data has loaded.
  factory MonthlySummary.empty({
    required MonthPeriod period,
    required Currency currency,
  }) => MonthlySummary.from(
    transactions: const <MoneyTransaction>[],
    period: period,
    currency: currency,
  );

  final MonthPeriod period;
  final Currency currency;
  final Money income;
  final Money expense;

  /// Expense totals keyed by category id. Unmodifiable.
  final Map<String, Money> expenseByCategory;

  /// Income totals keyed by category id. Unmodifiable.
  final Map<String, Money> incomeByCategory;

  /// Income minus expense — negative when the month runs at a loss.
  Money get net => income - expense;

  bool get isEmpty => income.isZero && expense.isZero;

  /// Expense breakdown, largest first — the order the chart and legend use.
  List<CategoryTotal> get expenseBreakdown {
    final entries =
        expenseByCategory.entries
            .map((entry) => CategoryTotal(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return entries;
  }

  /// What was spent in [categoryId], or zero when nothing was.
  Money spentOn(String categoryId) =>
      expenseByCategory[categoryId] ?? Money.zero(currency);
}
