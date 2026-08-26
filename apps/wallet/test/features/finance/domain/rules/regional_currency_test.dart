import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/regional_currency.dart';

void main() {
  test('picks the currency of the region', () {
    expect(currencyForRegion('TR'), Currency.turkishLira);
    expect(currencyForRegion('GB'), Currency.britishPound);
    expect(currencyForRegion('DE'), Currency.euro);
    expect(currencyForRegion('HR'), Currency.euro);
    expect(currencyForRegion('US'), Currency.usDollar);
    expect(currencyForRegion('CH'), Currency.swissFranc);
    expect(currencyForRegion('LI'), Currency.swissFranc);
    expect(currencyForRegion('MX'), Currency.mexicanPeso);
    expect(currencyForRegion('CA'), Currency.canadianDollar);
    expect(currencyForRegion('JP'), Currency.japaneseYen);
  });

  test('falls back to dollars for an unknown or absent region', () {
    expect(currencyForRegion('AU'), Currency.usDollar);
    expect(currencyForRegion(null), Currency.usDollar);
    expect(currencyForRegion(''), Currency.usDollar);
  });

  test('every answer is a currency the app can store', () {
    for (final code in [
      'TR',
      'GB',
      'DE',
      'US',
      'CH',
      'MX',
      'CA',
      'JP',
      'ZZ',
      null,
    ]) {
      expect(Currency.values, contains(currencyForRegion(code)));
    }
  });
}
