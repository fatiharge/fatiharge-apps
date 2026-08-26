import 'package:meta/meta.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';

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

/// Scoped to a single [currency] on purpose. Summing across currencies would
/// require exchange rates, which the app does not have; the dashboard instead
/// shows one currency at a time and lets the user switch.
@immutable
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

  final Map<String, Money> expenseByCategory;

  final Map<String, Money> incomeByCategory;

  Money get net => income - expense;

  bool get isEmpty => income.isZero && expense.isZero;

  List<CategoryTotal> get expenseBreakdown {
    final entries =
        expenseByCategory.entries
            .map((entry) => CategoryTotal(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return entries;
  }

  Money spentOn(String categoryId) =>
      expenseByCategory[categoryId] ?? Money.zero(currency);

  // Value equality so that a Cubit holding a summary can tell "the numbers
  // changed" from "the same numbers were recomputed".
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummary &&
          other.period == period &&
          other.currency == currency &&
          other.income == income &&
          other.expense == expense &&
          _sameTotals(other.expenseByCategory, expenseByCategory) &&
          _sameTotals(other.incomeByCategory, incomeByCategory);

  @override
  int get hashCode => Object.hash(
    period,
    currency,
    income,
    expense,
    Object.hashAllUnordered(
      expenseByCategory.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAllUnordered(
      incomeByCategory.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  static bool _sameTotals(Map<String, Money> a, Map<String, Money> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
