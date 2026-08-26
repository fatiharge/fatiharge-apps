import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/generated/locale_keys.g.dart';

import '../../../support/in_memory_repositories.dart';

/// The permission dance, which is where this feature can quietly lie to the
/// user: a switch that says on while nothing is scheduled, or a prompt spent
/// on someone who never asked to be asked.
void main() {
  late FakeSettingsRepository settings;
  late FakeSummaryNotifier notifier;
  late SummaryReminderController controller;

  setUp(() {
    settings = FakeSettingsRepository();
    notifier = FakeSummaryNotifier();
    controller = SummaryReminderController(settings, notifier);
  });

  test('turning it on asks once, then schedules', () async {
    final refusal = await controller.enable(day: 5);

    expect(refusal, isNull);
    expect(notifier.promptCount, 1);
    expect(notifier.scheduledDay, 5);
    expect(controller.reminder.enabled, isTrue);
    expect(controller.reminder.day, 5);
  });

  test('a refused prompt leaves it off and stores nothing', () async {
    notifier.grantOnRequest = false;

    final refusal = await controller.enable(day: 5);

    expect(refusal, ReminderRefusal.declined);
    expect(controller.reminder.enabled, isFalse);
    expect(notifier.scheduledDay, isNull);
  });

  test('the platform prompt is spent once and only once', () async {
    notifier.grantOnRequest = false;
    await controller.enable(day: 5);

    final second = await controller.enable(day: 5);

    // Asking again would do nothing on iOS, so the app must not pretend it
    // can — it reports blocked and offers system settings instead.
    expect(second, ReminderRefusal.blocked);
    expect(notifier.promptCount, 1);
  });

  test('already-granted permission skips the prompt entirely', () async {
    notifier.permitted = true;

    await controller.enable(day: 12);

    expect(notifier.promptCount, 0);
    expect(notifier.scheduledDay, 12);
  });

  test('turning it off cancels what was scheduled', () async {
    await controller.enable(day: 5);

    await controller.disable();

    expect(controller.reminder.enabled, isFalse);
    expect(notifier.scheduledDay, isNull);
    expect(notifier.cancelCount, greaterThan(0));
  });

  test('the chosen day survives being turned off', () async {
    await controller.enable(day: 20);
    await controller.disable();

    expect(controller.reminder.day, 20);
  });

  group('refresh', () {
    test('rewrites the window while it is on', () async {
      await controller.enable(day: 9);
      notifier.scheduledDay = null;

      await controller.refresh();

      expect(notifier.scheduledDay, 9);
    });

    test('does nothing while it is off', () async {
      await controller.refresh();

      expect(notifier.scheduledDay, isNull);
    });

    test(
      'turns itself off when permission went away outside the app',
      () async {
        await controller.enable(day: 9);
        notifier.permitted = false;

        await controller.refresh();

        // Otherwise settings would show a switch that is on and does nothing.
        expect(controller.reminder.enabled, isFalse);
      },
    );

    test('writes the words from localization, not from the caller', () async {
      await controller.enable(day: 9);

      // No translations are loaded in a unit test, so easy_localization echoes
      // the key back. That it appears at all is the point: the text is
      // resolved inside the controller rather than handed to it.
      expect(notifier.scheduledBody, LocaleKeys.settings_notification_body);
    });
  });
}
