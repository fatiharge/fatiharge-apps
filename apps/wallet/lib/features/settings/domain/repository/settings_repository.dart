import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Storage contract for the app's scalar preferences.
///
/// [readTheme] is synchronous on purpose. The theme has to be known before the
/// first frame or the app opens in the wrong one, and an async read would make
/// that impossible to express — the adapter loads its store before `runApp`
/// instead, and every read afterwards is from memory.
abstract interface class SettingsRepository {
  ThemePreference readTheme();

  Future<void> writeTheme(ThemePreference preference);

  /// What a new transaction or budget starts in. Falls back to the device's
  /// region until the user picks one.
  ///
  /// Only a default: existing records keep the currency they were written in,
  /// and changing this never rewrites them.
  Currency readCurrency();

  Future<void> writeCurrency(Currency currency);

  /// Whether the first-run flow has been through, skipped included. Read
  /// before the first route is chosen, so it is synchronous like the rest.
  bool isOnboarded();

  Future<void> completeOnboarding();

  /// The monthly summary reminder: whether it is on, and which day of the
  /// month it arrives. The day is stored as chosen, not as clamped — see
  /// `SummarySchedule`.
  MonthlySummaryReminder readSummaryReminder();

  Future<void> writeSummaryReminder(MonthlySummaryReminder reminder);

  /// Whether the platform's one-shot notification prompt has been put in front
  /// of the user yet.
  ///
  /// Separate from a denied permission on purpose. Someone who said no to
  /// *our* question can be asked again, because the platform prompt was never
  /// spent; someone who denied the platform prompt cannot, and can only be
  /// sent to system settings.
  bool wasNotificationPromptShown();

  Future<void> markNotificationPromptShown();

  /// How many times the dashboard has offered the reminder to someone who does
  /// not have it on, so the offer can stop rather than nag.
  int summaryNudgeCount();

  Future<void> recordSummaryNudge();

  /// Set when the user closes the offer for good.
  bool isSummaryNudgeDismissed();

  Future<void> dismissSummaryNudge();
}
