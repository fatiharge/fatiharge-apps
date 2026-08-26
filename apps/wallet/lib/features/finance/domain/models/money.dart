import 'package:meta/meta.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';

/// There are no exchange rates, so mixing currencies is a programming error.
class CurrencyMismatchException implements Exception {
  const CurrencyMismatchException(this.left, this.right);

  final Currency left;
  final Currency right;

  @override
  String toString() =>
      'CurrencyMismatchException: cannot combine ${left.code} with '
      '${right.code} — no conversion rates are available.';
}

/// Never `double`: `0.1 + 0.2 != 0.3`, and the error accumulates into totals
/// that visibly do not add up.
@immutable
class Money implements Comparable<Money> {
  const Money(this.amountMinor, this.currency);

  const Money.zero(this.currency) : amountMinor = 0;

  /// **Lossy.** `1.005` is already `1.00499…` before this sees it. For
  /// anything the user typed use [tryParse], which never goes through a double.
  factory Money.fromMajor(num major, Currency currency) =>
      Money((major * _factorFor(currency)).round(), currency);

  /// Both `,` and `.` are accepted — a Turkish keyboard produces a comma.
  /// Extra precision rounds half-up; `null` means not a number.
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

    // Half-up on the first dropped digit; the carry rides the combined
    // integer, so 9.999 -> 10.00 falls out for free.
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

  final int amountMinor;

  final Currency currency;

  bool get isZero => amountMinor == 0;

  bool get isNegative => amountMinor < 0;

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
