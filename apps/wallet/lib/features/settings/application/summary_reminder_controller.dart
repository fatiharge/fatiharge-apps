import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';
import 'package:wallet/generated/locale_keys.g.dart';

enum ReminderRefusal {
  declined,

  /// Refused before, so the prompt no longer appears — only system settings
  /// can undo it.
  blocked,
}

/// Not a cubit: two screens drive this and neither watches the other.
@injectable
class SummaryReminderController {
  SummaryReminderController(this._settings, this._notifier);

  final SettingsRepository _settings;
  final SummaryNotifier _notifier;

  MonthlySummaryReminder get reminder => _settings.readSummaryReminder();

  /// Returns `null` on success, or why it could not be done.
  Future<ReminderRefusal?> enable({required int day}) async {
    // Read before asking: _permitted() spends the prompt, after which every
    // refusal looks like an old one.
    final askedBefore = _settings.wasNotificationPromptShown();

    if (!await _permitted()) {
      return askedBefore ? ReminderRefusal.blocked : ReminderRefusal.declined;
    }

    await _settings.writeSummaryReminder(
      MonthlySummaryReminder(enabled: true, day: day),
    );
    await _schedule(day);
    return null;
  }

  Future<void> disable() async {
    await _settings.writeSummaryReminder(reminder.copyWith(enabled: false));
    await _notifier.cancel();
  }

  /// Called on launch: only a fixed number of occurrences are ever scheduled,
  /// and a language change since the last one lands here too.
  Future<void> refresh() async {
    final current = reminder;
    if (!current.enabled) return;

    if (!await _notifier.hasPermission()) {
      // Turned off outside the app; otherwise settings shows a live switch
      // that does nothing.
      await _settings.writeSummaryReminder(current.copyWith(enabled: false));
      return;
    }

    await _schedule(current.day);
  }

  Future<void> openSystemSettings() => _notifier.openSystemSettings();

  /// Translated here rather than passed in: `tr` resolves off the loaded
  /// localization, no widget needed.
  Future<void> _schedule(int day) => _notifier.schedule(
    day: day,
    title: tr(LocaleKeys.settings_notification_title),
    body: tr(LocaleKeys.settings_notification_body),
    channelName: tr(LocaleKeys.settings_notification_channel),
  );

  Future<bool> _permitted() async {
    if (await _notifier.hasPermission()) return true;
    if (_settings.wasNotificationPromptShown()) return false;

    // Recorded before the answer: a crash mid-prompt must not leave the app
    // believing it still has one.
    await _settings.markNotificationPromptShown();
    return _notifier.requestPermission();
  }
}
