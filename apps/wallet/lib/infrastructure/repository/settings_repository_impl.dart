import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/regional_currency.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Takes an already-loaded [SharedPreferences], which is what lets the reads
/// be synchronous. Registered by hand in `main.dart`; a generated registration
/// would resolve too late.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._preferences, {this.region});

  /// Namespaced: easy_localization keeps its own key in this same store.
  static const String themeKey = 'settings.theme';
  static const String currencyKey = 'settings.currency';
  static const String onboardedKey = 'settings.onboarded';
  static const String reminderEnabledKey = 'settings.reminder.enabled';
  static const String reminderDayKey = 'settings.reminder.day';
  static const String notificationPromptKey = 'settings.reminder.prompted';
  static const String nudgeCountKey = 'settings.reminder.nudges';
  static const String nudgeDismissedKey = 'settings.reminder.nudgeOff';
  static const String installedAtKey = 'settings.installedAt';
  static const String reviewAskedAtKey = 'settings.reviewAskedAt';

  final SharedPreferences _preferences;

  /// Passed in rather than read here, so this stays testable without a
  /// platform.
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

    // A preference is not worth crashing over, unlike a stored amount.
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

  @override
  DateTime? installedAt() => _readDate(installedAtKey);

  @override
  Future<void> recordInstall(DateTime at) => _writeDate(installedAtKey, at);

  @override
  DateTime? lastReviewRequestAt() => _readDate(reviewAskedAtKey);

  @override
  Future<void> recordReviewRequest(DateTime at) =>
      _writeDate(reviewAskedAtKey, at);

  /// Milliseconds, not ISO: an int cannot be half-parsed into a wrong day.
  DateTime? _readDate(String key) {
    final millis = _preferences.getInt(key);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _writeDate(String key, DateTime at) =>
      _preferences.setInt(key, at.millisecondsSinceEpoch);
}
