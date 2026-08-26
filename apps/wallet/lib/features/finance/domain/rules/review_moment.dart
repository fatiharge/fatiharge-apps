/// Whether now is a reasonable moment to ask for a store review.
///
/// The store APIs decide for themselves whether the dialog actually appears —
/// Apple allows roughly three a year, Play works to its own quota — and a call
/// that is thrown away still counts against that. So the app has one job: only
/// call at a moment worth spending.
///
/// The rules below are all about earning the ask. Nothing here nudges anyone
/// towards a particular score: asking for five stars, or routing unhappy users
/// somewhere else, is grounds for removal from both stores.
abstract final class ReviewMoment {
  /// Long enough to have formed an opinion. A day-one prompt asks someone who
  /// has not used the thing yet.
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
    // The moment itself: the user is looking at a month that has numbers in
    // it, which is the app having just done its job. Asking mid-task or after
    // an error is what makes these prompts hated.
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
