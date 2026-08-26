import 'package:injectable/injectable.dart';
import 'package:wallet/config/env.dart';
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';

/// Says nothing about what to write: prompting for a score, or routing unhappy
/// users elsewhere, is grounds for removal from both stores.
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

  Future<void> start() async {
    if (_settings.installedAt() != null) return;
    await _settings.recordInstall(clock());
  }

  /// Synchronous: an await here would put the answer a frame behind the
  /// screen it belongs to.
  bool isMoment({
    required int transactionCount,
    required bool viewingMonthWithData,
  }) {
    final now = clock();
    if (Env.debugGrowth) {
      // Only the waiting is moved out of the way; `viewingMonthWithData` is
      // not faked, since the moment is the thing worth seeing.
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

  /// Recorded whether or not a dialog appears: the store counts the call, not
  /// the sighting.
  Future<void> ask() async {
    if (!await _requester.isAvailable()) return;

    await _settings.recordReviewRequest(clock());
    await _requester.request();
  }
}
