import 'package:motto/features/chain/domain/reminder.dart';

/// What the app needs from the platform's notification system.
///
/// A port, so the rules above it can be tested without a plugin that only
/// answers on a real device.
abstract interface class ReminderScheduler {
  /// Asks once. Returns whether reminders may be sent from here on.
  Future<bool> requestPermission();

  /// Whether reminders are allowed right now. iOS cannot be asked without
  /// prompting, so it answers optimistically and scheduling simply has no
  /// effect when that turns out to be wrong.
  Future<bool> hasPermission();

  /// Replaces everything pending with [reminders].
  ///
  /// Replace rather than add: a scheduled notification cannot check anything
  /// when it fires, so the only way it stays correct is to rebuild the whole
  /// plan whenever the chain changes.
  Future<void> schedule(List<Reminder> reminders);

  Future<void> cancelAll();
}
