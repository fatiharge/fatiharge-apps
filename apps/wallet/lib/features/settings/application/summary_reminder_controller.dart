import 'package:injectable/injectable.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';

/// Why turning the reminder on did not work, so the screen can say something
/// more useful than nothing.
enum ReminderRefusal {
  /// The user said no to the platform prompt just now. It can be asked again.
  declined,

  /// The permission was refused before, so the prompt no longer appears and
  /// only system settings can undo it.
  blocked,
}

/// The reminder as a whole: the preference, the permission and the schedule,
/// which have to move together or the app lies to the user.
///
/// Not a cubit: two screens drive this — the first-run step and settings — and
/// neither watches the other. Each rebuilds itself after it acts.
@injectable
class SummaryReminderController {
  SummaryReminderController(this._settings, this._notifier);

  final SettingsRepository _settings;
  final SummaryNotifier _notifier;

  MonthlySummaryReminder get reminder => _settings.readSummaryReminder();

  /// Turns the reminder on for [day], asking for permission if it has not been
  /// asked for yet. Returns `null` on success, or why it could not be done.
  Future<ReminderRefusal?> enable({
    required int day,
    required SummaryNotificationText text,
  }) async {
    // Read before asking, not after: _permitted() spends the prompt and marks
    // it as spent, so afterwards every refusal would look like an old one.
    final askedBefore = _settings.wasNotificationPromptShown();

    if (!await _permitted()) {
      // Which of the two it is decides what the screen offers next: asking
      // again, or a trip to system settings.
      return askedBefore ? ReminderRefusal.blocked : ReminderRefusal.declined;
    }

    await _settings.writeSummaryReminder(
      MonthlySummaryReminder(enabled: true, day: day),
    );
    await _notifier.schedule(
      day: day,
      title: text.title,
      body: text.body,
      channelName: text.channelName,
    );
    return null;
  }

  Future<void> disable() async {
    await _settings.writeSummaryReminder(reminder.copyWith(enabled: false));
    await _notifier.cancel();
  }

  /// Rewrites the scheduled window so it keeps rolling forward.
  ///
  /// Only a fixed number of occurrences are scheduled at a time — the day has
  /// to be clamped per month, so there is no single repeating rule to hand the
  /// platform. Called on launch. Also the moment a language change reaches the
  /// notification text, which was written when it was last scheduled.
  Future<void> refresh(SummaryNotificationText text) async {
    final current = reminder;
    if (!current.enabled) return;

    if (!await _notifier.hasPermission()) {
      // Turned off outside the app. Reflecting that here stops settings from
      // showing a switch that does nothing.
      await _settings.writeSummaryReminder(current.copyWith(enabled: false));
      return;
    }

    await _notifier.schedule(
      day: current.day,
      title: text.title,
      body: text.body,
      channelName: text.channelName,
    );
  }

  Future<void> openSystemSettings() => _notifier.openSystemSettings();

  Future<bool> _permitted() async {
    if (await _notifier.hasPermission()) return true;
    if (_settings.wasNotificationPromptShown()) return false;

    // The one shot. Recorded before the answer so a crash mid-prompt cannot
    // make the app believe it still has one.
    await _settings.markNotificationPromptShown();
    return _notifier.requestPermission();
  }
}

/// The words a scheduled notification carries, resolved by the caller because
/// only a widget has the context to translate them.
class SummaryNotificationText {
  const SummaryNotificationText({
    required this.title,
    required this.body,
    required this.channelName,
  });

  final String title;
  final String body;
  final String channelName;
}
