import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/regional_currency.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// SharedPreferences-backed [SettingsRepository].
///
/// Takes an already-loaded [SharedPreferences] rather than calling
/// `getInstance()` itself, which is what lets [readTheme] be synchronous. It
/// is registered by hand in `main.dart` for the same reason the router is:
/// the theme is needed before the DI container is built.
///
/// Not annotated for injectable — a generated registration would resolve too
/// late to be of any use here.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._preferences, {this.region});

  /// Namespaced because easy_localization keeps its own `locale` key in this
  /// same store.
  static const String themeKey = 'settings.theme';
  static const String currencyKey = 'settings.currency';
  static const String onboardedKey = 'settings.onboarded';
  static const String reminderEnabledKey = 'settings.reminder.enabled';
  static const String reminderDayKey = 'settings.reminder.day';
  static const String notificationPromptKey = 'settings.reminder.prompted';
  static const String nudgeCountKey = 'settings.reminder.nudges';
  static const String nudgeDismissedKey = 'settings.reminder.nudgeOff';

  final SharedPreferences _preferences;

  /// ISO 3166-1 alpha-2 code of the device's region, passed in rather than
  /// read here so this stays testable without a platform.
  final String? region;

  @override
  ThemePreference readTheme() =>
      ThemePreference.fromStorage(_preferences.getString(themeKey));

  @override
  Future<void> writeTheme(ThemePreference preference) =>
      _preferences.setString(themeKey, preference.storageKey);

  @override
  Currency readCurrency() {
    final stored = _preferences.getString(currencyKey);

    // A dropped currency code falls back rather than throwing: a preference is
    // not worth crashing over, unlike a stored transaction amount.
    return Currency.values.where((c) => c.code == stored).firstOrNull ??
        currencyForRegion(region);
  }

  @override
  Future<void> writeCurrency(Currency currency) =>
      _preferences.setString(currencyKey, currency.code);

  @override
  bool isOnboarded() => _preferences.getBool(onboardedKey) ?? false;

  @override
  Future<void> completeOnboarding() => _preferences.setBool(onboardedKey, true);

  @override
  MonthlySummaryReminder readSummaryReminder() => MonthlySummaryReminder(
    enabled: _preferences.getBool(reminderEnabledKey) ?? false,
    day: _preferences.getInt(reminderDayKey) ?? MonthlySummaryReminder.off.day,
  );

  @override
  Future<void> writeSummaryReminder(MonthlySummaryReminder reminder) async {
    await _preferences.setBool(reminderEnabledKey, reminder.enabled);
    await _preferences.setInt(reminderDayKey, reminder.day);
  }

  @override
  bool wasNotificationPromptShown() =>
      _preferences.getBool(notificationPromptKey) ?? false;

  @override
  Future<void> markNotificationPromptShown() =>
      _preferences.setBool(notificationPromptKey, true);

  @override
  int summaryNudgeCount() => _preferences.getInt(nudgeCountKey) ?? 0;

  @override
  Future<void> recordSummaryNudge() =>
      _preferences.setInt(nudgeCountKey, summaryNudgeCount() + 1);

  @override
  bool isSummaryNudgeDismissed() =>
      _preferences.getBool(nudgeDismissedKey) ?? false;

  @override
  Future<void> dismissSummaryNudge() =>
      _preferences.setBool(nudgeDismissedKey, true);
}
