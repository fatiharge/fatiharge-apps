import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/result/presentation/result_page.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:motto/theme/motto_theme.dart';

class _MockAnalytics extends Mock implements Analytics {}

void main() {
  late _MockAnalytics analytics;

  setUpAll(() => registerFallbackValue(MottoEvent.appOpen));

  // The page reports that it was seen, so the container has to answer for it
  // the same way it does in the app.
  setUp(() {
    analytics = _MockAnalytics();
    when(
      () => analytics.record(any(), properties: any(named: 'properties')),
    ).thenAnswer((_) async {});
    getIt.registerSingleton<Analytics>(analytics);
  });

  tearDown(getIt.reset);

  final result = api.ResultResponse(
    archetype: api.ArchetypeResponse(
      id: 'quiet_builder',
      name: 'Sessiz İnşacı',
      summary: 'Gürültü çıkarmadan biriktirirsin.',
      motto: 'Acele etmeyen ama durmayan.',
      confident: true,
    ),
    entitlement: api.EntitlementResponse(
      remainingUses: 1,
      skipsLeft: 1,
      premium: false,
    ),
  );

  Widget page({
    Future<void> Function(BuildContext, api.ArchetypeResponse)? offerCard,
  }) => MaterialApp(
    theme: MottoTheme.dark,
    home: ResultPage(
      result: result,
      offerCard: offerCard ?? (_, _) async {},
    ),
  );

  testWidgets('shows the archetype, what it means and the motto', (
    tester,
  ) async {
    await tester.pumpWidget(page());

    expect(find.text('Sessiz İnşacı'), findsOneWidget);
    expect(find.text('Gürültü çıkarmadan biriktirirsin.'), findsOneWidget);
    expect(find.text('“Acele etmeyen ama durmayan.”'), findsOneWidget);

    // The page schedules the card offer; let it fire so no timer outlives the
    // tree.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('renders in both themes', (tester) async {
    for (final theme in [MottoTheme.light, MottoTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: ResultPage(result: result, offerCard: (_, _) async {}),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  });

  testWidgets('offers the card by itself, after the result has been read', (
    tester,
  ) async {
    api.ArchetypeResponse? offered;
    await tester.pumpWidget(
      page(offerCard: (_, archetype) async => offered = archetype),
    );

    // Not immediately: the result is what was asked for, and a sheet that
    // arrives on top of it reads as an interruption.
    expect(offered, isNull);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // And not never: the share rate is the only thing this version measures,
    // and a screen someone has to go looking for measures nothing.
    expect(offered?.name, 'Sessiz İnşacı');
  });

  testWidgets('reports that the result was seen', (tester) async {
    await tester.pumpWidget(page());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    verify(() => analytics.record(MottoEvent.resultView)).called(1);
  });
}
