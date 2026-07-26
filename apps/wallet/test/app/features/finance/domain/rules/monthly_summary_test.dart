import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/rules/currency_usage.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';
import 'package:wallet/app/features/finance/domain/rules/monthly_summary.dart';

import '../../../../../support/finance_fixtures.dart';

void main() {
  const july = MonthPeriod(2026, 7);
  const try_ = Currency.turkishLira;
  const usd = Currency.usDollar;

  MonthlySummary summarise(
    List<dynamic> transactions, {
    Currency currency = try_,
  }) => MonthlySummary.from(
    transactions: transactions.cast(),
    period: july,
    currency: currency,
  );

  group('MonthlySummary', () {
    test('totals income and expense separately', () {
      final summary = summarise([
        incomeOf(500000, on: DateTime(2026, 7, 1)),
        expenseOf(12000, on: DateTime(2026, 7, 3)),
        expenseOf(8000, on: DateTime(2026, 7, 9)),
      ]);

      expect(summary.income, const Money(500000, try_));
      expect(summary.expense, const Money(20000, try_));
      expect(summary.net, const Money(480000, try_));
    });

    test('ignores transactions outside the period', () {
      final summary = summarise([
        expenseOf(10000, on: DateTime(2026, 6, 30)),
        expenseOf(20000, on: DateTime(2026, 7, 15)),
        expenseOf(30000, on: DateTime(2026, 8)),
      ]);

      expect(summary.expense, const Money(20000, try_));
    });

    test('ignores other currencies instead of adding them up', () {
      final summary = summarise([
        expenseOf(10000),
        expenseOf(99999, currency: usd),
      ]);

      expect(summary.expense, const Money(10000, try_));
      expect(summary.currency, try_);
    });

    test('groups expenses by category', () {
      final summary = summarise([
        expenseOf(5000, category: 'food'),
        expenseOf(3000, category: 'food'),
        expenseOf(9000, category: 'transport'),
        incomeOf(100000, category: 'salary'),
      ]);

      expect(summary.expenseByCategory['food'], const Money(8000, try_));
      expect(summary.expenseByCategory['transport'], const Money(9000, try_));
      expect(summary.expenseByCategory.containsKey('salary'), isFalse);
      expect(summary.incomeByCategory['salary'], const Money(100000, try_));
    });

    test('expenseBreakdown is ordered largest first', () {
      final summary = summarise([
        expenseOf(1000, category: 'food'),
        expenseOf(9000, category: 'rent'),
        expenseOf(5000, category: 'transport'),
      ]);

      expect(
        summary.expenseBreakdown.map((slice) => slice.categoryId).toList(),
        ['rent', 'transport', 'food'],
      );
    });

    test('spentOn returns zero for an untouched category', () {
      final summary = summarise([expenseOf(1000, category: 'food')]);

      expect(summary.spentOn('travel'), const Money.zero(try_));
    });

    test('an empty month is zero, not null', () {
      final summary = MonthlySummary.empty(period: july, currency: try_);

      expect(summary.isEmpty, isTrue);
      expect(summary.net, const Money.zero(try_));
      expect(summary.expenseBreakdown, isEmpty);
    });

    test('the returned breakdown maps are unmodifiable', () {
      final summary = summarise([expenseOf(1000)]);

      expect(
        () => summary.expenseByCategory['hack'] = const Money(1, try_),
        throwsUnsupportedError,
      );
    });
  });

  group('currenciesUsed', () {
    test('lists only the currencies actually present, in enum order', () {
      final used = currenciesUsed([
        expenseOf(100, currency: usd),
        expenseOf(100),
        incomeOf(100, currency: usd),
      ]);

      expect(used, [try_, usd]);
    });

    test('is empty when there are no transactions', () {
      expect(currenciesUsed(const []), isEmpty);
    });
  });
}
