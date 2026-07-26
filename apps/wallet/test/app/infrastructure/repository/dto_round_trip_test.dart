import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/domain/models/budget.dart';
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/infrastructure/repository/dto/budget_dto.dart';
import 'package:wallet/app/infrastructure/repository/dto/category_dto.dart';
import 'package:wallet/app/infrastructure/repository/dto/transaction_dto.dart';

/// The DTOs are hand-written, so the round trip is where a mistyped key or a
/// dropped field would show up. Nothing else in the app can catch that.
void main() {
  group('TransactionDto', () {
    final transaction = MoneyTransaction(
      id: 't1',
      type: TransactionType.expense,
      categoryId: 'food',
      amount: const Money(12345, Currency.usDollar),
      date: DateTime(2026, 7, 15, 13, 30),
      note: 'Lunch',
    );

    test('survives encode/decode unchanged', () {
      final decoded = TransactionDto.decode(TransactionDto.encode(transaction));

      expect(decoded, transaction);
    });

    test(
      'keeps a null note null rather than turning it into an empty string',
      () {
        final withoutNote = transaction.copyWith(note: null);

        final decoded = TransactionDto.decode(
          TransactionDto.encode(withoutNote),
        );

        expect(decoded.note, isNull);
      },
    );

    test('preserves the currency, not just the amount', () {
      final decoded = TransactionDto.decode(TransactionDto.encode(transaction));

      expect(decoded.amount.currency, Currency.usDollar);
      expect(decoded.amount.amountMinor, 12345);
    });

    test('preserves the date down to the minute', () {
      final decoded = TransactionDto.decode(TransactionDto.encode(transaction));

      expect(decoded.date, DateTime(2026, 7, 15, 13, 30));
    });

    test('rejects a record with an unknown currency instead of guessing', () {
      final record = TransactionDto.encode(transaction)..['currency'] = 'XXX';

      expect(() => TransactionDto.decode(record), throwsArgumentError);
    });
  });

  group('CategoryDto', () {
    const category = Category(
      id: 'food',
      name: 'Yemek',
      icon: CategoryIcon.food,
      colorArgb: 0xFFE57373,
      archived: true,
    );

    test('survives encode/decode unchanged', () {
      expect(CategoryDto.decode(CategoryDto.encode(category)), category);
    });

    test(
      'defaults archived to false for records written before it existed',
      () {
        final record = CategoryDto.encode(category)..remove('archived');

        expect(CategoryDto.decode(record).archived, isFalse);
      },
    );
  });

  group('BudgetDto', () {
    const budget = Budget(
      id: 'b1',
      limit: Money(50000, Currency.euro),
      categoryId: 'transport',
    );

    test('survives encode/decode unchanged', () {
      expect(BudgetDto.decode(BudgetDto.encode(budget)), budget);
    });

    test(
      'round-trips an overall budget as a null category, not a blank one',
      () {
        const overall = Budget(id: 'b2', limit: Money(1, Currency.turkishLira));

        final decoded = BudgetDto.decode(BudgetDto.encode(overall));

        expect(decoded.categoryId, isNull);
        expect(decoded.isOverall, isTrue);
      },
    );
  });
}
