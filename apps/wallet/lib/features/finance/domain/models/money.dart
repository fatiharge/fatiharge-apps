import 'package:meta/meta.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';

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
@immutable
class Money implements Comparable<Money> {
  const Money(this.amountMinor, this.currency);

  const Money.zero(this.currency) : amountMinor = 0;

  /// Builds a [Money] from a major-unit value, e.g. `123.45` -> `12345`.
  ///
  /// **Lossy by construction.** [major] is a binary float, so values like
  /// `1.005` are already `1.00499…` before this method sees them and round
  /// *down*. Use it for values that came out of arithmetic we control (chart
  /// maths, tests); for anything the user typed use [tryParse], which never
  /// goes through a double.
  factory Money.fromMajor(num major, Currency currency) =>
      Money((major * _factorFor(currency)).round(), currency);

  /// Parses user input like `12,50`, `1250`, `-3.7` into minor units without
  /// ever constructing a double.
  ///
  /// Accepts both `,` and `.` as the decimal separator — Turkish keyboards
  /// produce a comma and rejecting it would be a bug, not strictness. Extra
  /// precision is rounded half-up. Returns `null` when the text is not a
  /// number, so callers can drive form validation from it.
  static Money? tryParse(String input, Currency currency) {
    final normalized = input.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;

    final isNegative = normalized.startsWith('-');
    final unsigned = isNegative ? normalized.substring(1) : normalized;

    // A lone sign or separator ('-', '.') would otherwise parse as zero.
    if (!_hasDigit.hasMatch(unsigned)) return null;

    final parts = unsigned.split('.');
    if (parts.length > 2) return null;

    final whole = parts.first.isEmpty ? '0' : parts.first;
    final fraction = parts.length == 2 ? parts[1] : '';
    if (!_digitsOnly.hasMatch(whole)) return null;
    if (fraction.isNotEmpty && !_digitsOnly.hasMatch(fraction)) return null;

    final digits = currency.decimalDigits;
    final kept = fraction.length > digits
        ? fraction.substring(0, digits)
        : fraction.padRight(digits, '0');

    final minor = int.tryParse('$whole$kept');
    if (minor == null) return null;

    // Round half-up on the first dropped digit; the carry rides along the
    // combined integer, so 9.999 -> 10.00 falls out for free.
    final roundsUp =
        fraction.length > digits && fraction.codeUnitAt(digits) >= _five;
    final rounded = roundsUp ? minor + 1 : minor;

    return Money(isNegative ? -rounded : rounded, currency);
  }

  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _hasDigit = RegExp(r'\d');
  static const int _five = 0x35;

  static int _factorFor(Currency currency) {
    var factor = 1;
    for (var i = 0; i < currency.decimalDigits; i++) {
      factor *= 10;
    }
    return factor;
  }

  /// The amount in minor units. Negative values are allowed.
  final int amountMinor;

  final Currency currency;

  bool get isZero => amountMinor == 0;

  bool get isNegative => amountMinor < 0;

  /// The amount in major units — for display and charts only.
  double get amountMajor => amountMinor / _factorFor(currency);

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
  int compareTo(Money other) => amountMinor.compareTo(_sameCurrency(other));

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
