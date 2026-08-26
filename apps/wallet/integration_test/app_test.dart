import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/main.dart' as app;

/// The only test that runs the real app: real Hive on the device's storage and
/// real platform channels. Everything in `test/` runs against fakes.
///
///     fvm flutter test integration_test/app_test.dart -d <device>
///
/// Not in `melos run test`: it needs a device, and CI has none.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Many short pumps rather than one long one: a single `pump(12s)` leaves the
  // localization delegate unresolved and the tree empty, and `pumpAndSettle`
  // never returns while the splash's indeterminate bar is on screen.
  Future<Finder?> waitForAny(
    WidgetTester tester,
    List<Finder> finders, {
    int seconds = 60,
  }) async {
    for (var tick = 0; tick < seconds * 10; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
      for (final finder in finders) {
        if (finder.evaluate().isNotEmpty) return finder;
      }
    }
    return null;
  }

  testWidgets('boots on real storage, then arms and disarms the reminder', (
    tester,
  ) async {
    await app.startApp();

    final tabs = find.byType(NavigationBar);
    final skip = find.text('Atla');

    var landed = await waitForAny(tester, [tabs, skip]);
    expect(landed, isNotNull, reason: 'bootstrap never handed over');

    if (landed == skip) {
      await tester.tap(skip);
      landed = await waitForAny(tester, [tabs]);
      expect(landed, isNotNull);
    }

    final reminders = getIt<SummaryReminderController>();
    final settings = getIt<SettingsRepository>();

    if (settings.readSummaryReminder().enabled) await reminders.disable();

    // The part no other test reaches: a real permission check and a real
    // zonedSchedule over the platform channel.
    expect(await reminders.enable(day: 9), isNull);
    expect(settings.readSummaryReminder().enabled, isTrue);

    await reminders.disable();
    expect(settings.readSummaryReminder().enabled, isFalse);
  });
}
