import 'package:wallet/features/finance/domain/models/currency.dart';

/// The euro-area members, by ISO 3166-1 alpha-2 code.
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

/// What a fresh install starts in, from the device's region.
///
/// The region, not the app language: someone in Germany reading the app in
/// English is far likelier to want euros than dollars. Dollars are the last
/// resort rather than lira because [Currency] only carries four, and an
/// unrecognised region is more often outside Turkey than in it.
///
/// This is a first guess, nothing more — the user can change it in settings,
/// and each transaction still carries its own currency.
Currency currencyForRegion(String? countryCode) => switch (countryCode) {
  'TR' => Currency.turkishLira,
  'GB' => Currency.britishPound,
  final code? when _euroArea.contains(code) => Currency.euro,
  _ => Currency.usDollar,
};
