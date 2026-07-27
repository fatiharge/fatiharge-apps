/// A currency the app can track money in.
///
/// [decimalDigits] is what separates the *minor* unit (what we store) from the
/// *major* unit (what the user reads): `12345` minor units of [turkishLira] is
/// `123.45 ₺`. Zero-decimal currencies exist (JPY), so this is a per-currency
/// property rather than a global constant.
enum Currency {
  turkishLira('TRY', '₺', 2),
  usDollar('USD', r'$', 2),
  euro('EUR', '€', 2),
  britishPound('GBP', '£', 2);

  const Currency(this.code, this.symbol, this.decimalDigits);

  /// ISO 4217 code, e.g. `TRY`. This is what gets persisted.
  final String code;

  /// Display symbol, e.g. `₺`.
  final String symbol;

  /// How many minor units make up one major unit (`2` means 100 minor units).
  final int decimalDigits;

  /// Resolves a [Currency] from its ISO [code].
  ///
  /// Throws [ArgumentError] for an unknown code — persisted data carrying a
  /// currency we no longer support should fail loudly, not silently default.
  static Currency fromCode(String code) => values.firstWhere(
    (currency) => currency.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown currency'),
  );
}
