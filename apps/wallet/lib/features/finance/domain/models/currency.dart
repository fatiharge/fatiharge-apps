/// Zero-decimal currencies exist (JPY), so [decimalDigits] is per-currency
/// rather than a global constant.
enum Currency {
  turkishLira('TRY', '₺', 2),
  usDollar('USD', r'$', 2),
  euro('EUR', '€', 2),
  britishPound('GBP', '£', 2);

  const Currency(this.code, this.symbol, this.decimalDigits);

  /// What gets persisted.
  final String code;

  final String symbol;

  /// `2` means 100 minor units to one major.
  final int decimalDigits;

  /// Throws for an unknown code: persisted data must fail loudly, not default.
  static Currency fromCode(String code) => values.firstWhere(
    (currency) => currency.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown currency'),
  );
}
