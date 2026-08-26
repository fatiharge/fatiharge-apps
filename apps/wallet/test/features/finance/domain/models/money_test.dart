import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

void main() {
  group('Money', () {
    const try_ = Currency.turkishLira;
    const usd = Currency.usDollar;

    test('adds and subtracts within one currency', () {
      expect(
        const Money(1050, try_) + const Money(2550, try_),
        const Money(3600, try_),
      );
      expect(
        const Money(1050, try_) - const Money(2550, try_),
        const Money(-1500, try_),
      );
    });

    test('refuses to mix currencies instead of silently converting', () {
      expect(
        () => const Money(100, try_) + const Money(100, usd),
        throwsA(isA<CurrencyMismatchException>()),
      );
      expect(
        () => const Money(100, try_) > const Money(100, usd),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('equality is by amount *and* currency', () {
      expect(const Money(100, try_), const Money(100, try_));
      expect(const Money(100, try_), isNot(const Money(100, usd)));
      expect(
        const Money(100, try_).hashCode,
        const Money(100, try_).hashCode,
      );
    });

    test('fromMajor rounds to the currency precision', () {
      expect(Money.fromMajor(123.45, try_), const Money(12345, try_));
      expect(Money.fromMajor(0.1 + 0.2, try_), const Money(30, try_));
    });

    test('fromMajor is lossy for values a double cannot hold', () {
      // 1.005 is really 1.00499… in binary, so it rounds *down*. This is why
      // user input must go through tryParse instead.
      expect(Money.fromMajor(1.005, try_), const Money(100, try_));
      expect(Money.tryParse('1.005', try_), const Money(101, try_));
    });

    test('tryParse accepts both decimal separators', () {
      expect(Money.tryParse('12,50', try_), const Money(1250, try_));
      expect(Money.tryParse('12.50', try_), const Money(1250, try_));
      expect(Money.tryParse(' 12,5 ', try_), const Money(1250, try_));
      expect(Money.tryParse('1250', try_), const Money(125000, try_));
    });

    test('tryParse pads, rounds half-up and carries', () {
      expect(Money.tryParse('7', try_), const Money(700, try_));
      expect(Money.tryParse('7.1', try_), const Money(710, try_));
      expect(Money.tryParse('7.126', try_), const Money(713, try_));
      expect(Money.tryParse('7.124', try_), const Money(712, try_));
      expect(Money.tryParse('9.999', try_), const Money(1000, try_));
    });

    test('tryParse handles signs and bare separators', () {
      expect(Money.tryParse('-3.7', try_), const Money(-370, try_));
      expect(Money.tryParse('.5', try_), const Money(50, try_));
    });

    test('tryParse returns null for anything that is not a number', () {
      expect(Money.tryParse('', try_), isNull);
      expect(Money.tryParse('abc', try_), isNull);
      expect(Money.tryParse('1.2.3', try_), isNull);
      expect(Money.tryParse('1e5', try_), isNull);
      expect(Money.tryParse('-', try_), isNull);
    });

    test('amountMajor converts back for display', () {
      expect(const Money(12345, try_).amountMajor, 123.45);
      expect(const Money(0, try_).amountMajor, 0.0);
    });

    test('ratioOf returns null against a zero divisor', () {
      expect(const Money(50, try_).ratioOf(const Money(200, try_)), 0.25);
      expect(const Money(50, try_).ratioOf(const Money(0, try_)), isNull);
    });

    test('negation and abs keep the currency', () {
      expect(-const Money(100, usd), const Money(-100, usd));
      expect(const Money(-100, usd).abs(), const Money(100, usd));
    });

    test('sums of many small amounts stay exact', () {
      // The float trap this type exists to avoid: 0.1 summed 10 times.
      var total = const Money.zero(try_);
      for (var i = 0; i < 10; i++) {
        total += const Money(10, try_);
      }
      expect(total, const Money(100, try_));
      expect(total.amountMajor, 1.0);
    });
  });

  group('Currency', () {
    test('resolves by ISO code', () {
      expect(Currency.fromCode('TRY'), Currency.turkishLira);
      expect(Currency.fromCode('EUR'), Currency.euro);
    });

    test('throws on an unknown code rather than defaulting', () {
      expect(() => Currency.fromCode('XXX'), throwsArgumentError);
    });
  });

  group('zero-decimal currencies', () {
    const jpy = Currency.japaneseYen;

    test('a minor unit is a major unit', () {
      expect(const Money(1200, jpy).amountMajor, 1200);
      expect(Money.fromMajor(1200, jpy), const Money(1200, jpy));
    });

    test('typed input does not gain a hundred-fold', () {
      expect(Money.tryParse('1200', jpy), const Money(1200, jpy));
    });

    test('typed decimals are rounded away, not carried', () {
      expect(Money.tryParse('1200,4', jpy), const Money(1200, jpy));
      expect(Money.tryParse('1200,5', jpy), const Money(1201, jpy));
    });
  });
}
