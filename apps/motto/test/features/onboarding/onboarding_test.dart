import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/onboarding/application/onboarding_store.dart';
import 'package:motto/features/onboarding/presentation/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late OnboardingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = OnboardingStore(await SharedPreferences.getInstance());
    getIt.registerSingleton<OnboardingStore>(store);
  });

  tearDown(getIt.reset);

  test('it has not been seen until it has', () async {
    expect(store.seen, isFalse);

    await store.markSeen();

    expect(store.seen, isTrue);
  });

  Widget page({
    Future<void> Function(BuildContext, {required bool takeTest})? onDone,
  }) => MaterialApp(
    home: OnboardingPage(onDone: onDone ?? (_, {required takeTest}) async {}),
  );

  testWidgets('it walks through its steps', (tester) async {
    await tester.pumpWidget(page());

    expect(find.text('Merhaba'), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);

    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    expect(find.text('Merhaba'), findsNothing);

    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    // The last step starts rather than continues; a "Devam" that goes nowhere
    // is the button people press twice.
    expect(find.text('Başla'), findsOneWidget);
  });

  testWidgets('skipping counts as seeing it', (tester) async {
    await tester.pumpWidget(page());

    await tester.tap(find.text('Geç'));
    await tester.pump();

    // Otherwise it comes back on the next launch, which is how a skip button
    // becomes a joke.
    expect(store.seen, isTrue);
  });

  testWidgets('it survives having no mascot to move', (tester) async {
    // The page is reachable before the host exists — in a test, and on a first
    // frame — and it may not fail for the want of an animation.
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('finishing goes to the questions, skipping does not', (
    tester,
  ) async {
    final asked = <bool>[];
    await tester.pumpWidget(
      page(onDone: (_, {required takeTest}) async => asked.add(takeTest)),
    );

    await tester.tap(find.text('Geç'));
    await tester.pump();
    expect(asked, [false]);

    await tester.pumpWidget(
      page(onDone: (_, {required takeTest}) async => asked.add(takeTest)),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Başla'));
    await tester.pump();

    expect(asked, [false, true]);
  });
}
