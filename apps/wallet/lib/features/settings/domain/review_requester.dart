/// A port because `in_app_review` needs a platform channel no widget test has,
/// and because the dialog cannot be observed even on a device — the store
/// decides whether to show it.
abstract interface class ReviewRequester {
  Future<bool> isAvailable();

  /// It very often shows nothing: the quota is the store's, not ours. That is
  /// normal and must not be retried — retrying spends the quota without ever
  /// reaching a user.
  Future<void> request();
}
