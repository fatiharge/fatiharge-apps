import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Every read is synchronous: the theme has to be known before the first
/// frame, so the adapter loads its store before `runApp`.
abstract interface class SettingsRepository {
  ThemePreference readTheme();

  Future<void> writeTheme(ThemePreference preference);

  /// Only a default: existing records keep the currency they were written in.
  Currency readCurrency();

  Future<void> writeCurrency(Currency currency);

  /// Skipping counts as through.
  bool isOnboarded();

  Future<void> completeOnboarding();

  /// The day is stored as chosen, not as clamped — see `SummarySchedule`.
  MonthlySummaryReminder readSummaryReminder();

  Future<void> writeSummaryReminder(MonthlySummaryReminder reminder);

  /// Not the same as a denied permission: someone who said no to *our*
  /// question can be asked again, because the platform prompt was never spent.
  bool wasNotificationPromptShown();

  Future<void> markNotificationPromptShown();

  /// So the offer can stop rather than nag.
  int summaryNudgeCount();

  Future<void> recordSummaryNudge();

  bool isSummaryNudgeDismissed();

  Future<void> dismissSummaryNudge();

  /// Null until the first launch records it.
  DateTime? installedAt();

  Future<void> recordInstall(DateTime at);

  DateTime? lastReviewRequestAt();

  Future<void> recordReviewRequest(DateTime at);
}
