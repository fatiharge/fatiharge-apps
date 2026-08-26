/// A call the store throws away still counts against its quota, so the app's
/// only job is to call at a moment worth spending. Nothing here nudges towards
/// a score — that is grounds for removal from both stores.
abstract final class ReviewMoment {
  /// Long enough to have formed an opinion.
  static const Duration minimumAge = Duration(days: 14);

  /// Enough records that the month's summary is theirs rather than a demo.
  static const int minimumTransactions = 10;

  /// A refused or ignored ask is an answer. Leave it a season before the next.
  static const Duration quietPeriod = Duration(days: 120);

  static bool shouldAsk({
    required DateTime now,
    required DateTime? installedAt,
    required DateTime? lastAskedAt,
    required int transactionCount,
    required bool viewingMonthWithData,
  }) {
    // The app having just done its job. Asking mid-task or after an error is
    // what makes these prompts hated.
    if (!viewingMonthWithData) return false;

    if (transactionCount < minimumTransactions) return false;

    if (installedAt == null) return false;
    if (now.difference(installedAt) < minimumAge) return false;

    if (lastAskedAt != null && now.difference(lastAskedAt) < quietPeriod) {
      return false;
    }

    return true;
  }
}
