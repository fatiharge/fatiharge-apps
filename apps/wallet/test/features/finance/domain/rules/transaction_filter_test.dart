import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';

import '../../../../support/finance_fixtures.dart';

void main() {
  final transactions = [
    expenseOf(1000, category: 'food', on: DateTime(2026, 7, 2), note: 'Lunch'),
    expenseOf(2000, category: 'rent', on: DateTime(2026, 7, 5)),
    incomeOf(90000, category: 'salary', on: DateTime(2026, 7)),
    expenseOf(
      3000,
      category: 'food',
      on: DateTime(2026, 6, 20),
      currency: Currency.usDollar,
    ),
  ];

  group('TransactionFilter', () {
    test('an empty filter matches everything', () {
      const filter = TransactionFilter();

      expect(filter.isEmpty, isTrue);
      expect(filter.apply(transactions), hasLength(transactions.length));
    });

    test('filters by type', () {
      const filter = TransactionFilter(type: TransactionType.income);

      expect(filter.apply(transactions).map((t) => t.categoryId), ['salary']);
    });

    test('filters by category set', () {
      const filter = TransactionFilter(categoryIds: {'food', 'rent'});

      expect(filter.apply(transactions), hasLength(3));
    });

    test('filters by currency', () {
      const filter = TransactionFilter(currency: Currency.usDollar);

      expect(filter.apply(transactions), hasLength(1));
    });

    test('filters by period', () {
      const filter = TransactionFilter(period: MonthPeriod(2026, 7));

      expect(filter.apply(transactions), hasLength(3));
    });

    test('note search is case-insensitive and trimmed', () {
      const filter = TransactionFilter(query: '  lUnCh ');

      expect(filter.apply(transactions), hasLength(1));
    });

    test('conditions combine with AND', () {
      const filter = TransactionFilter(
        type: TransactionType.expense,
        categoryIds: {'food'},
        period: MonthPeriod(2026, 7),
      );

      expect(filter.apply(transactions), hasLength(1));
    });

    test('results come back newest first', () {
      const filter = TransactionFilter(period: MonthPeriod(2026, 7));

      final dates = filter.apply(transactions).map((t) => t.date).toList();
      expect(dates, [
        DateTime(2026, 7, 5),
        DateTime(2026, 7, 2),
        DateTime(2026, 7),
      ]);
    });

    test('copyWith can clear a field as well as set it', () {
      const filter = TransactionFilter(type: TransactionType.expense);

      expect(filter.copyWith(clearType: true).type, isNull);
      expect(
        filter.copyWith(type: TransactionType.income).type,
        TransactionType.income,
      );
    });

    test('value equality ignores category set ordering', () {
      const a = TransactionFilter(categoryIds: {'food', 'rent'});
      const b = TransactionFilter(categoryIds: {'rent', 'food'});

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
