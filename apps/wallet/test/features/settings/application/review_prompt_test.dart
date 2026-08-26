import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';

import '../../../support/in_memory_repositories.dart';

void main() {
  final now = DateTime(2026, 8, 12);

  late FakeSettingsRepository settings;
  late _FakeRequester requester;
  late ReviewPrompt prompt;

  setUp(() {
    settings = FakeSettingsRepository();
    requester = _FakeRequester();
    prompt = ReviewPrompt(settings, requester, clock: () => now);
  });

  /// The two halves as their callers pair them: the bloc decides the moment,
  /// whoever takes the effect does the asking.
  Future<void> ask() async {
    final moment = prompt.isMoment(
      transactionCount: 50,
      viewingMonthWithData: true,
    );
    if (!moment) return;

    await prompt.ask();
  }

  test('records the install date once and never moves it', () async {
    await prompt.start();
    expect(settings.installed, now);

    // A later launch must not reset the clock, or the app would never be old
    // enough to ask.
    prompt = ReviewPrompt(
      settings,
      requester,
      clock: () => now.add(const Duration(days: 30)),
    );
    await prompt.start();

    expect(settings.installed, now);
  });

  test('asks when the moment qualifies', () async {
    settings.installed = now.subtract(ReviewMoment.minimumAge);

    await ask();

    expect(requester.requests, 1);
    expect(settings.reviewAskedAt, now);
  });

  test('stays silent when the moment does not', () async {
    settings.installed = now;

    await ask();

    expect(requester.requests, 0);
    expect(settings.reviewAskedAt, isNull);
  });

  test('does not ask when the platform says it cannot', () async {
    settings.installed = now.subtract(ReviewMoment.minimumAge);
    requester.available = false;

    await ask();

    expect(requester.requests, 0);
    // Nothing was spent, so nothing is recorded — the next qualifying moment
    // should still get its turn.
    expect(settings.reviewAskedAt, isNull);
  });

  test('counts the call, not the dialog', () async {
    settings.installed = now.subtract(ReviewMoment.minimumAge);

    await ask();
    await ask();

    // The store decides whether anything appeared; asking twice in a row would
    // burn its quota against a user who never saw a thing.
    expect(requester.requests, 1);
  });
}

class _FakeRequester implements ReviewRequester {
  bool available = true;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> request() async => requests++;
}
