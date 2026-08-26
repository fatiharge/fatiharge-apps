import 'package:wallet/features/finance/domain/models/currency.dart';

const _euroArea = {
  'AT',
  'BE',
  'HR',
  'CY',
  'EE',
  'FI',
  'FR',
  'DE',
  'GR',
  'IE',
  'IT',
  'LV',
  'LT',
  'LU',
  'MT',
  'NL',
  'PT',
  'SK',
  'SI',
  'ES',
};

/// The region, not the app language: someone in Germany reading in English
/// still wants euros. A first guess only — settings can change it.
Currency currencyForRegion(String? countryCode) => switch (countryCode) {
  'TR' => Currency.turkishLira,
  'GB' => Currency.britishPound,
  final code? when _euroArea.contains(code) => Currency.euro,
  _ => Currency.usDollar,
};
