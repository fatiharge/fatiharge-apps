import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app.dart';
import 'package:wallet/features/onboarding/presentation/page/onboarding_page.dart';

import '../../support/app_harness.dart';
import '../../support/finance_fixtures.dart';
import '../../support/widget_harness.dart';

/// Where startup hands over. Covered through the real `App` because the
/// decision is made in `BootstrapAdapter.bootstrapFinished()` and carried out
/// by the router — asserting on either half alone would prove neither.
void main() {
  late AppHarness harness;

  tearDown(() => harness.dispose());

  Future<void> boot(WidgetTester tester, {required bool onboarded}) async {
    harness = await registerAppDependencies(onboarded: onboarded);
    harness.categories.seed([
      categoryOf('food', nameKey: 'category.food'),
      categoryOf('gift', nameKey: 'category.gift'),
    ]);

    useTallSurface(tester);
    await pumpApp(tester, const App());
    // bootstrap_kit pads the splash to a minimum duration; let that timer run.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('a first launch opens the onboarding flow', (tester) async {
    await boot(tester, onboarded: false);

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text("Warizo'ya hoş geldin"), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('every launch after it goes straight to the tabs', (
    tester,
  ) async {
    await boot(tester, onboarded: true);

    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('skipping lands on the tabs and does not come back', (
    tester,
  ) async {
    await boot(tester, onboarded: false);

    await tester.tap(find.text('Atla'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
    expect(harness.settings.onboarded, isTrue);
  });

  testWidgets('walking the flow through archives what was unticked', (
    tester,
  ) async {
    await boot(tester, onboarded: false);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Hediye'));
    await tester.pumpAndSettle();

    // One more step now: the reminder offer sits after the categories.
    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    final stored = {
      for (final category in await harness.categories.fetchAll())
        category.id: category,
    };
    expect(stored['gift']!.archived, isTrue);
    expect(stored['food']!.archived, isFalse);
  });
}
