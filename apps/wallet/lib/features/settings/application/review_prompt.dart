import 'package:injectable/injectable.dart';
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';

/// Decides when to hand the store its one chance to ask for a review.
///
/// Deliberately says nothing about what the user should write. Prompting for a
/// particular score, or steering unhappy users to a feedback form instead of
/// the store, is grounds for removal from both stores — so the app's only
/// influence is *when* it asks.
@injectable
class ReviewPrompt {
  ReviewPrompt(
    this._settings,
    this._requester, {
    @ignoreParam this.clock = systemClock,
  });

  final SettingsRepository _settings;
  final ReviewRequester _requester;
  final Clock clock;

  /// Records the first launch, so age can be measured later.
  Future<void> start() async {
    if (_settings.installedAt() != null) return;
    await _settings.recordInstall(clock());
  }

  /// Asks, if this is a moment worth spending.
  ///
  /// Marked as asked whether or not a dialog appears: the store counts the
  /// call, not the sighting, so treating a silent call as "did not happen"
  /// would burn the quota in a loop.
  Future<void> maybeAsk({
    required int transactionCount,
    required bool viewingMonthWithData,
  }) async {
    final now = clock();
    final due = ReviewMoment.shouldAsk(
      now: now,
      installedAt: _settings.installedAt(),
      lastAskedAt: _settings.lastReviewRequestAt(),
      transactionCount: transactionCount,
      viewingMonthWithData: viewingMonthWithData,
    );
    if (!due) return;

    if (!await _requester.isAvailable()) return;

    await _settings.recordReviewRequest(now);
    await _requester.request();
  }
}
