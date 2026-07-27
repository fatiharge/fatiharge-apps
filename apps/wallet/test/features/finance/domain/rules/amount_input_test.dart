import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/amount_input.dart';

void main() {
  const try_ = Currency.turkishLira;

  group('readAmount', () {
    test('accepts a positive amount and returns no problem', () {
      final reading = readAmount('12,50', try_);

      expect(reading.money, const Money(1250, try_));
      expect(reading.problem, isNull);
    });

    test('empty or blank text is missing, not invalid', () {
      expect(readAmount('', try_).problem, AmountProblem.missing);
      expect(readAmount('   ', try_).problem, AmountProblem.missing);
    });

    test('text that is not a number is reported as such', () {
      expect(readAmount('abc', try_).problem, AmountProblem.notANumber);
      expect(readAmount('1.2.3', try_).problem, AmountProblem.notANumber);
      expect(readAmount('-', try_).problem, AmountProblem.notANumber);
    });

    test('zero and negative are rejected', () {
      expect(readAmount('0', try_).problem, AmountProblem.notPositive);
      expect(readAmount('0,00', try_).problem, AmountProblem.notPositive);
      expect(readAmount('-5', try_).problem, AmountProblem.notPositive);
    });

    test('a rejected reading carries no money', () {
      for (final text in ['', 'abc', '0', '-5']) {
        expect(readAmount(text, try_).money, isNull, reason: 'for "$text"');
      }
    });

    test('the currency comes back on the parsed amount', () {
      expect(readAmount('7,25', Currency.euro).money?.currency, Currency.euro);
    });

    test('an amount below one minor unit does not round up into validity', () {
      // 0.004 rounds to 0 kuruş, which is not recordable.
      expect(readAmount('0,004', try_).problem, AmountProblem.notPositive);
    });
  });
}
