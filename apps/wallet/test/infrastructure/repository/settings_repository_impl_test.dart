import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
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

  group('the monthly reminder', () {
    test('starts off, on the first of the month', () async {
      final reminder = (await build()).readSummaryReminder();

      expect(reminder.enabled, isFalse);
      expect(reminder.day, 1);
    });

    test('survives a write and a reopen', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await SettingsRepositoryImpl(preferences).writeSummaryReminder(
        const MonthlySummaryReminder(enabled: true, day: 17),
      );

      final reopened = SettingsRepositoryImpl(
        preferences,
      ).readSummaryReminder();
      expect(reopened.enabled, isTrue);
      expect(reopened.day, 17);
    });

    test('remembers that the platform prompt has been spent', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final settings = SettingsRepositoryImpl(preferences);

      expect(settings.wasNotificationPromptShown(), isFalse);
      await settings.markNotificationPromptShown();

      // Across a relaunch too: the platform will not show it again either.
      expect(
        SettingsRepositoryImpl(preferences).wasNotificationPromptShown(),
        isTrue,
      );
    });

    test('counts the offers made, and the closing of them', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final settings = SettingsRepositoryImpl(preferences);

      expect(settings.summaryNudgeCount(), 0);
      await settings.recordSummaryNudge();
      await settings.recordSummaryNudge();
      expect(settings.summaryNudgeCount(), 2);

      expect(settings.isSummaryNudgeDismissed(), isFalse);
      await settings.dismissSummaryNudge();
      expect(settings.isSummaryNudgeDismissed(), isTrue);
    });
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
