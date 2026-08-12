import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/presentation/views/reminder_section.dart';

import '../../../support/in_memory_repositories.dart';
import '../../../support/widget_harness.dart';

void main() {
  late FakeSettingsRepository settings;
  late FakeSummaryNotifier notifier;

  setUp(() async {
    settings = FakeSettingsRepository();
    notifier = FakeSummaryNotifier();
    await getIt.reset();
    getIt.registerSingleton<SummaryReminderController>(
      SummaryReminderController(settings, notifier),
    );
  });

  tearDown(getIt.reset);

  Future<void> pumpSection(WidgetTester tester) {
    useTallSurface(tester);
    return pumpLocalized(tester, const ReminderSettings());
  }

  testWidgets('starts off, and hides the day until it is on', (tester) async {
    await pumpSection(tester);

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.text('Ayın günü'), findsNothing);
  });

  testWidgets('turning it on asks, schedules, and reveals the day', (
    tester,
  ) async {
    await pumpSection(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(notifier.promptCount, 1);
    expect(notifier.scheduledDay, 1);
    expect(find.text('Ayın günü'), findsOneWidget);
    expect(settings.reminder.enabled, isTrue);
  });

  testWidgets('picking a day reschedules on it', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '15'));
    await tester.pumpAndSettle();

    expect(notifier.scheduledDay, 15);
    expect(settings.reminder.day, 15);
  });

  testWidgets('turning it off cancels and hides the day again', (
    tester,
  ) async {
    settings.reminder = const MonthlySummaryReminder(enabled: true, day: 3);
    notifier.permitted = true;
    await pumpSection(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(settings.reminder.enabled, isFalse);
    expect(notifier.cancelCount, greaterThan(0));
    expect(find.text('Ayın günü'), findsNothing);
  });

  testWidgets('a refused prompt says nothing the first time', (tester) async {
    notifier.grantOnRequest = false;
    await pumpSection(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // The user has just answered; explaining their own answer back is noise.
    expect(find.textContaining('Sistem ayarlarından'), findsNothing);
  });

  testWidgets('a blocked permission offers the way out', (tester) async {
    notifier.grantOnRequest = false;
    settings.notificationPromptShown = true;
    await pumpSection(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sistem ayarlarından'), findsOneWidget);

    await tester.tap(find.text('Ayarları aç'));
    await tester.pumpAndSettle();

    expect(notifier.settingsOpened, 1);
    // The prompt is spent, so it must not be fired again.
    expect(notifier.promptCount, 0);
  });
}
