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

  final archetype = api.ArchetypeResponse(
    id: 'quiet_builder',
    name: 'Sessiz İnşacı',
    summary: 'Gürültü çıkarmadan biriktirirsin.',
    motto: 'Acele etmeyen ama durmayan.',
    confident: true,
  );

  Widget page({
    Future<void> Function(BuildContext, api.ArchetypeResponse)? offerCard,
  }) => MaterialApp(
    theme: MottoTheme.dark,
    home: ResultPage(
      archetype: archetype,
      resultId: 1,
      justClaimed: true,
      offerCard: offerCard ?? (_, _) async {},
    ),
  );

  testWidgets('shows the archetype, what it means and the motto', (
    tester,
  ) async {
    await tester.pumpWidget(page());

    expect(find.text('Sessiz İnşacı'), findsOneWidget);
    expect(find.text('Gürültü çıkarmadan biriktirirsin.'), findsOneWidget);
    // Unquoted and on its own block now: the motto is the app, and it read
    // like a caption under the summary.
    expect(find.text('Acele etmeyen ama durmayan.'), findsOneWidget);
    expect(find.text('MOTTON'), findsOneWidget);

    // The page schedules the card offer; let it fire so no timer outlives the
    // tree.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('renders in both themes', (tester) async {
    for (final theme in [MottoTheme.light, MottoTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: ResultPage(
            archetype: archetype,
            resultId: 1,
            offerCard: (_, _) async {},
          ),
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

  testWidgets('an old result is read, not celebrated', (tester) async {
    var offered = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(
          archetype: archetype,
          resultId: 1,
          offerCard: (_, _) async => offered = true,
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Pushing the share card at somebody who came to look something up is an
    // interruption.
    expect(offered, isFalse);
    expect(find.text('Sessiz İnşacı'), findsOneWidget);
  });

  testWidgets('there is a way back out of it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MottoTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultPage(
                      archetype: archetype,
                      resultId: 1,
                      offerCard: (_, _) async {},
                    ),
                  ),
                ),
                child: const Text('nereden geldiysem'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('nereden geldiysem'));
    await tester.pumpAndSettle();
    expect(find.text('Sessiz İnşacı'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Four screens open this one, and the funnel puts the shell under it, so
    // behind it is always somewhere to be. Until now nothing said so: the page
    // had no bar at all and the only way out was the system gesture.
    expect(find.text('nereden geldiysem'), findsOneWidget);
  });
}
