/// What the app needs from the platform's notification service.
///
/// A port rather than a direct dependency so the cubits stay testable: none of
/// them can run against `flutter_local_notifications`, which needs a platform
/// channel that no widget test has.
abstract interface class SummaryNotifier {
  /// Shows the platform's permission prompt. Returns whether it was granted.
  ///
  /// One shot on iOS: once denied, calling this again does nothing and the
  /// user has to be sent to system settings instead. Only call it for someone
  /// who has already said yes to being asked.
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  /// Replaces whatever was scheduled with reminders on [day] of each month.
  ///
  /// Enumerated rather than left to repeat, because a day past the end of a
  /// short month would otherwise be skipped entirely. Call it on launch so the
  /// scheduled window keeps rolling forward.
  ///
  /// [title] and [body] are passed in already translated: a notification's
  /// text is written when it is scheduled, months before delivery, so it
  /// cannot be resolved later. Rescheduling on launch is what keeps it in the
  /// language the user is now reading.
  Future<void> schedule({
    required int day,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> cancel();

  /// Opens the system settings page for this app, for the one case the app
  /// cannot recover from on its own — a denied platform permission.
  Future<void> openSystemSettings();
}
