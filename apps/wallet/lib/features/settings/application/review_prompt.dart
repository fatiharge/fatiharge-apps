import 'package:injectable/injectable.dart';
import 'package:wallet/config/env.dart';
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';

/// Decides when to hand the store its one chance to ask for a review, and
/// takes it when told to.
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

  /// Whether now is a moment worth spending the store's quota on.
  ///
  /// Synchronous because every input already is: the caller is a cubit
  /// deciding what to announce while it builds a state, and an await there
  /// would put the answer a frame behind the screen it belongs to.
  bool isMoment({
    required int transactionCount,
    required bool viewingMonthWithData,
  }) {
    final now = clock();
    if (Env.debugGrowth) {
      // The rule is left exactly as it ships; only the waiting it measures is
      // moved out of the way. `viewingMonthWithData` is deliberately not
      // faked — the moment itself is the thing worth seeing.
      return ReviewMoment.shouldAsk(
        now: now,
        installedAt: now.subtract(ReviewMoment.minimumAge),
        lastAskedAt: null,
        transactionCount: ReviewMoment.minimumTransactions,
        viewingMonthWithData: viewingMonthWithData,
      );
    }

    return ReviewMoment.shouldAsk(
      now: now,
      installedAt: _settings.installedAt(),
      lastAskedAt: _settings.lastReviewRequestAt(),
      transactionCount: transactionCount,
      viewingMonthWithData: viewingMonthWithData,
    );
  }

  /// Asks the store to show its dialog.
  ///
  /// Marked as asked whether or not a dialog appears: the store counts the
  /// call, not the sighting, so treating a silent call as "did not happen"
  /// would burn the quota in a loop.
  Future<void> ask() async {
    if (!await _requester.isAvailable()) return;

    await _settings.recordReviewRequest(clock());
    await _requester.request();
  }
}
