import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/infrastructure/repository/settings_repository_impl.dart';

void main() {
  Future<SettingsRepositoryImpl> build({
    Map<String, Object> stored = const {},
    String? region,
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    return SettingsRepositoryImpl(
      await SharedPreferences.getInstance(),
      region: region,
    );
  }

  test('a fresh install starts in the currency of its region', () async {
    expect((await build(region: 'DE')).readCurrency(), Currency.euro);
    expect((await build(region: 'TR')).readCurrency(), Currency.turkishLira);
  });

  test('a stored choice outranks the region', () async {
    final settings = await build(
      stored: {SettingsRepositoryImpl.currencyKey: 'USD'},
      region: 'TR',
    );

    expect(settings.readCurrency(), Currency.usDollar);
  });

  test(
    'a currency the app no longer carries falls back, it does not throw',
    () async {
      final settings = await build(
        stored: {SettingsRepositoryImpl.currencyKey: 'XXX'},
        region: 'GB',
      );

      expect(settings.readCurrency(), Currency.britishPound);
    },
  );

  test('the choice survives a write and a reopen', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await SettingsRepositoryImpl(
      preferences,
      region: 'TR',
    ).writeCurrency(Currency.euro);

    // A second instance over the same store stands in for the next launch.
    expect(
      SettingsRepositoryImpl(preferences, region: 'TR').readCurrency(),
      Currency.euro,
    );
  });

  test('the theme is untouched by any of this', () async {
    final settings = await build(
      stored: {
        SettingsRepositoryImpl.themeKey: ThemePreference.dark.storageKey,
      },
    );

    expect(settings.readTheme(), ThemePreference.dark);
  });
}
