import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';

import '../../../support/in_memory_repositories.dart';

/// The permission dance, which is where this feature can quietly lie to the
/// user: a switch that says on while nothing is scheduled, or a prompt spent
/// on someone who never asked to be asked.
void main() {
  late FakeSettingsRepository settings;
  late FakeSummaryNotifier notifier;
  late SummaryReminderController controller;

  const text = SummaryNotificationText(
    title: 'Warizo',
    body: 'Ayın özeti hazır',
    channelName: 'Aylık özet',
  );

  setUp(() {
    settings = FakeSettingsRepository();
    notifier = FakeSummaryNotifier();
    controller = SummaryReminderController(settings, notifier);
  });

  test('turning it on asks once, then schedules', () async {
    final refusal = await controller.enable(day: 5, text: text);

    expect(refusal, isNull);
    expect(notifier.promptCount, 1);
    expect(notifier.scheduledDay, 5);
    expect(controller.reminder.enabled, isTrue);
    expect(controller.reminder.day, 5);
  });

  test('a refused prompt leaves it off and stores nothing', () async {
    notifier.grantOnRequest = false;

    final refusal = await controller.enable(day: 5, text: text);

    expect(refusal, ReminderRefusal.declined);
    expect(controller.reminder.enabled, isFalse);
    expect(notifier.scheduledDay, isNull);
  });

  test('the platform prompt is spent once and only once', () async {
    notifier.grantOnRequest = false;
    await controller.enable(day: 5, text: text);

    final second = await controller.enable(day: 5, text: text);

    // Asking again would do nothing on iOS, so the app must not pretend it
    // can — it reports blocked and offers system settings instead.
    expect(second, ReminderRefusal.blocked);
    expect(notifier.promptCount, 1);
  });

  test('already-granted permission skips the prompt entirely', () async {
    notifier.permitted = true;

    await controller.enable(day: 12, text: text);

    expect(notifier.promptCount, 0);
    expect(notifier.scheduledDay, 12);
  });

  test('turning it off cancels what was scheduled', () async {
    await controller.enable(day: 5, text: text);

    await controller.disable();

    expect(controller.reminder.enabled, isFalse);
    expect(notifier.scheduledDay, isNull);
    expect(notifier.cancelCount, greaterThan(0));
  });

  test('the chosen day survives being turned off', () async {
    await controller.enable(day: 20, text: text);
    await controller.disable();

    expect(controller.reminder.day, 20);
  });

  group('refresh', () {
    test('rewrites the window while it is on', () async {
      await controller.enable(day: 9, text: text);
      notifier.scheduledDay = null;

      await controller.refresh(text);

      expect(notifier.scheduledDay, 9);
    });

    test('does nothing while it is off', () async {
      await controller.refresh(text);

      expect(notifier.scheduledDay, isNull);
    });

    test(
      'turns itself off when permission went away outside the app',
      () async {
        await controller.enable(day: 9, text: text);
        notifier.permitted = false;

        await controller.refresh(text);

        // Otherwise settings would show a switch that is on and does nothing.
        expect(controller.reminder.enabled, isFalse);
      },
    );

    test('carries the language it is called with', () async {
      await controller.enable(day: 9, text: text);

      await controller.refresh(
        const SummaryNotificationText(
          title: 'Warizo',
          body: 'Your monthly summary is ready',
          channelName: 'Monthly summary',
        ),
      );

      expect(notifier.scheduledBody, 'Your monthly summary is ready');
    });
  });
}
