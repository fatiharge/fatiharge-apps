/// The store's own review dialog.
///
/// A port because `in_app_review` needs a platform channel no widget test has,
/// and because the dialog cannot be observed even on a device — the store
/// decides whether to show it.
abstract interface class ReviewRequester {
  /// Whether the platform is in a state where asking is possible at all.
  Future<bool> isAvailable();

  /// Asks the store to show its review dialog.
  ///
  /// It very often shows nothing: the quota is the store's, not ours. That is
  /// normal and must not be retried — retrying spends the quota without ever
  /// reaching a user.
  Future<void> request();
}
