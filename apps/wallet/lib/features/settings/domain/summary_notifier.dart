abstract interface class SummaryNotifier {
  /// One shot on iOS: once denied, calling this again does nothing and the
  /// user has to be sent to system settings.
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  /// [title] and [body] arrive translated: the text is written when it is
  /// scheduled, months before delivery.
  Future<void> schedule({
    required int day,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> cancel();

  Future<void> openSystemSettings();
}
