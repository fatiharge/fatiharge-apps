import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallet/main.dart' as app;

/// End-to-end on a real device or emulator, against real Hive.
///
/// The widget tests run against fakes and never touch storage; this is the
/// only thing that proves a transaction written on one screen comes back on
/// another after the round trip through disk.
///
///     flutter test integration_test/app_test.dart -d <device>
///
/// Not part of `melos run test`: it needs a device, and CI has none.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('records an expense and sees it in the totals', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '125');
    await tester.pumpAndSettle();

    // The first category chip, whatever the seed produced.
    await tester.tap(find.byType(ChoiceChip).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Back on the dashboard, the amount is part of the month's expense.
    expect(find.textContaining('125'), findsWidgets);
  });

  testWidgets('the recorded expense survives a restart', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();

    expect(
      find.text('Geçmiş boş'),
      findsNothing,
      reason: 'the transaction from the previous test came off disk',
    );
  });
}
