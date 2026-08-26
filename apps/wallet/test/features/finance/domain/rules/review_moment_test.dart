import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';

void main() {
  final now = DateTime(2026, 8, 12);
  final longEnoughAgo = now.subtract(ReviewMoment.minimumAge);

  bool ask({
    DateTime? installedAt,
    DateTime? lastAskedAt,
    int transactionCount = ReviewMoment.minimumTransactions,
    bool viewingMonthWithData = true,
  }) => ReviewMoment.shouldAsk(
    now: now,
    installedAt: installedAt ?? longEnoughAgo,
    lastAskedAt: lastAskedAt,
    transactionCount: transactionCount,
    viewingMonthWithData: viewingMonthWithData,
  );

  test('asks once every condition is met', () {
    expect(ask(), isTrue);
  });

  test('never outside the moment itself', () {
    // Everything else in place, but the user is not looking at a month that
    // has anything in it — so the app has not just done anything worth
    // reviewing.
    expect(ask(viewingMonthWithData: false), isFalse);
  });

  test('not before the app has been used enough', () {
    expect(
      ask(transactionCount: ReviewMoment.minimumTransactions - 1),
      isFalse,
    );
  });

  test('not on a fresh install', () {
    expect(ask(installedAt: now), isFalse);
    expect(
      ask(
        installedAt: now.subtract(
          ReviewMoment.minimumAge - const Duration(days: 1),
        ),
      ),
      isFalse,
    );
  });

  test('not when the install date was never recorded', () {
    expect(
      ReviewMoment.shouldAsk(
        now: now,
        installedAt: null,
        lastAskedAt: null,
        transactionCount: 50,
        viewingMonthWithData: true,
      ),
      isFalse,
    );
  });

  group('after a previous ask', () {
    test('stays quiet through the quiet period', () {
      expect(ask(lastAskedAt: now.subtract(const Duration(days: 1))), isFalse);
      expect(
        ask(
          lastAskedAt: now.subtract(
            ReviewMoment.quietPeriod - const Duration(days: 1),
          ),
        ),
        isFalse,
      );
    });

    test('asks again once it has passed', () {
      expect(ask(lastAskedAt: now.subtract(ReviewMoment.quietPeriod)), isTrue);
    });
  });
}
