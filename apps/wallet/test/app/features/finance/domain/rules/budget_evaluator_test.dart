import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';
import 'package:wallet/app/features/finance/domain/rules/monthly_summary.dart';

import '../../../../../support/finance_fixtures.dart';

void main() {
  const july = MonthPeriod(2026, 7);
  const try_ = Currency.turkishLira;
  const usd = Currency.usDollar;

  MonthlySummary summaryOf(
    List<MoneyTransaction> transactions, {
    Currency currency = try_,
  }) => MonthlySummary.from(
    transactions: transactions,
    period: july,
    currency: currency,
  );

  group('BudgetEvaluator', () {
    test('a category budget only counts that category', () {
      final summary = summaryOf([
        expenseOf(6000, category: 'food'),
        expenseOf(90000, category: 'rent'),
      ]);

      final statuses = BudgetEvaluator.evaluate(
        budgets: [budgetOf(10000, category: 'food')],
        summary: summary,
      );

      expect(statuses.single.spent, const Money(6000, try_));
      expect(statuses.single.ratio, closeTo(0.6, 0.0001));
      expect(statuses.single.health, BudgetHealth.safe);
      expect(statuses.single.remaining, const Money(4000, try_));
    });

    test('an overall budget counts every expense', () {
      final summary = summaryOf([
        expenseOf(6000),
        expenseOf(4000, category: 'rent'),
      ]);

      final statuses = BudgetEvaluator.evaluate(
        budgets: [budgetOf(20000)],
        summary: summary,
      );

      expect(statuses.single.spent, const Money(10000, try_));
      expect(statuses.single.budget.isOverall, isTrue);
    });

    test('warns at 80% and flags exceeded at 100%', () {
      final atWarning = BudgetEvaluator.evaluate(
        budgets: [budgetOf(10000, category: 'food')],
        summary: summaryOf([expenseOf(8000, category: 'food')]),
      ).single;
      expect(atWarning.health, BudgetHealth.warning);
      expect(atWarning.isExceeded, isFalse);

      final atLimit = BudgetEvaluator.evaluate(
        budgets: [budgetOf(10000, category: 'food')],
        summary: summaryOf([expenseOf(10000, category: 'food')]),
      ).single;
      expect(atLimit.health, BudgetHealth.exceeded);
      expect(atLimit.remaining, const Money.zero(try_));

      final over = BudgetEvaluator.evaluate(
        budgets: [budgetOf(10000, category: 'food')],
        summary: summaryOf([expenseOf(12500, category: 'food')]),
      ).single;
      expect(over.health, BudgetHealth.exceeded);
      expect(over.remaining, const Money(-2500, try_));
    });

    test('skips budgets in a different currency', () {
      final statuses = BudgetEvaluator.evaluate(
        budgets: [
          budgetOf(10000, category: 'food', currency: usd, id: 'usd'),
          budgetOf(10000, category: 'food', id: 'try'),
        ],
        summary: summaryOf([expenseOf(12000, category: 'food')]),
      );

      expect(statuses.map((status) => status.budget.id), ['try']);
    });

    test('orders the most-at-risk budget first', () {
      final statuses = BudgetEvaluator.evaluate(
        budgets: [
          budgetOf(10000, category: 'food', id: 'food'),
          budgetOf(10000, category: 'rent', id: 'rent'),
          budgetOf(10000, category: 'fun', id: 'fun'),
        ],
        summary: summaryOf([
          expenseOf(1000, category: 'food'),
          expenseOf(9500, category: 'rent'),
          expenseOf(5000, category: 'fun'),
        ]),
      );

      expect(
        statuses.map((status) => status.budget.id).toList(),
        ['rent', 'fun', 'food'],
      );
    });

    test('a zero limit is blown by any spending, but not by none', () {
      final spent = BudgetEvaluator.evaluate(
        budgets: [budgetOf(0, category: 'food')],
        summary: summaryOf([expenseOf(1, category: 'food')]),
      ).single;
      expect(spent.health, BudgetHealth.exceeded);

      final untouched = BudgetEvaluator.evaluate(
        budgets: [budgetOf(0, category: 'food')],
        summary: summaryOf(const []),
      ).single;
      expect(untouched.health, BudgetHealth.safe);
    });

    test('income does not consume a budget', () {
      final statuses = BudgetEvaluator.evaluate(
        budgets: [budgetOf(10000)],
        summary: summaryOf([incomeOf(50000)]),
      );

      expect(statuses.single.spent, const Money.zero(try_));
    });

    test('exceeded returns only the blown budgets', () {
      final blown = BudgetEvaluator.exceeded(
        budgets: [
          budgetOf(10000, category: 'food', id: 'food'),
          budgetOf(10000, category: 'rent', id: 'rent'),
        ],
        summary: summaryOf([
          expenseOf(11000, category: 'food'),
          expenseOf(500, category: 'rent'),
        ]),
      );

      expect(blown.map((status) => status.budget.id), ['food']);
    });
  });
}
