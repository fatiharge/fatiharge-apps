import 'package:wallet/app/features/finance/domain/models/currency.dart';

/// Thrown when two [Money] values of different currencies are combined.
///
/// The app deliberately has no exchange rates (that needs a backend), so
/// mixing currencies is a programming error, not a runtime condition to
/// recover from.
class CurrencyMismatchException implements Exception {
  const CurrencyMismatchException(this.left, this.right);

  final Currency left;
  final Currency right;

  @override
  String toString() =>
      'CurrencyMismatchException: cannot combine ${left.code} with '
      '${right.code} — no conversion rates are available.';
}

/// An amount of money, stored in *minor* units (kuruş, cents).
///
/// Never use `double` for money: `0.1 + 0.2 != 0.3` in binary floating point,
/// and those errors accumulate into totals that visibly do not add up.
class Money implements Comparable<Money> {
  const Money(this.amountMinor, this.currency);

  const Money.zero(this.currency) : amountMinor = 0;

  /// Builds a [Money] from a major-unit value, e.g. `123.45` -> `12345`.
  ///
  /// Rounds to the currency's precision; intended for parsing user input, not
  /// for arithmetic.
  factory Money.fromMajor(num major, Currency currency) {
    var factor = 1;
    for (var i = 0; i < currency.decimalDigits; i++) {
      factor *= 10;
    }
    return Money((major * factor).round(), currency);
  }

  /// The amount in minor units. Negative values are allowed.
  final int amountMinor;

  final Currency currency;

  bool get isZero => amountMinor == 0;

  bool get isNegative => amountMinor < 0;

  /// The amount in major units — for display and charts only.
  double get amountMajor {
    var factor = 1;
    for (var i = 0; i < currency.decimalDigits; i++) {
      factor *= 10;
    }
    return amountMinor / factor;
  }

  Money operator +(Money other) =>
      Money(amountMinor + _sameCurrency(other), currency);

  Money operator -(Money other) =>
      Money(amountMinor - _sameCurrency(other), currency);

  Money operator -() => Money(-amountMinor, currency);

  bool operator >(Money other) => amountMinor > _sameCurrency(other);

  bool operator >=(Money other) => amountMinor >= _sameCurrency(other);

  bool operator <(Money other) => amountMinor < _sameCurrency(other);

  bool operator <=(Money other) => amountMinor <= _sameCurrency(other);

  Money abs() => Money(amountMinor.abs(), currency);

  /// [amountMinor] as a fraction of [other], or `null` when [other] is zero.
  double? ratioOf(Money other) {
    final divisor = _sameCurrency(other);
    if (divisor == 0) return null;
    return amountMinor / divisor;
  }

  int _sameCurrency(Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatchException(currency, other.currency);
    }
    return other.amountMinor;
  }

  @override
  int compareTo(Money other) =>
      amountMinor.compareTo(_sameCurrency(other));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          other.amountMinor == amountMinor &&
          other.currency == currency;

  @override
  int get hashCode => Object.hash(amountMinor, currency);

  @override
  String toString() => 'Money($amountMinor ${currency.code})';
}
