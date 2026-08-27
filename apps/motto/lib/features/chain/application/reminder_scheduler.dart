import 'package:motto/features/chain/domain/reminder.dart';

/// A port, so the rules above it can be tested without a plugin that only
/// answers on a real device.
abstract interface class ReminderScheduler {
  /// Asks once. Returns whether reminders may be sent from here on.
  Future<bool> requestPermission();

  /// iOS cannot be asked without prompting, so it answers optimistically.
  Future<bool> hasPermission();

  /// Replaces everything pending: a scheduled notification cannot check
  /// anything when it fires, so the plan is rebuilt rather than appended to.
  Future<void> schedule(List<Reminder> reminders);

  Future<void> cancelAll();
}
