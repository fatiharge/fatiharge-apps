import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/game/application/turns_cubit.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/features/profile/presentation/profile_page.dart';

class _MockResults extends Mock implements api.ResultResourceApi {}

class _MockEntitlements extends Mock implements api.EntitlementResourceApi {}

class _MockTurns extends Mock implements api.PlayResourceApi {}

api.ResultSummary _summary() => api.ResultSummary(
  id: 1,
  archetype: api.ArchetypeResponse(
    id: 'quiet_builder',
    name: 'Sessiz İnşacı',
    summary: 'Gürültü çıkarmadan biriktirirsin.',
    motto: 'Acele etmeyen ama durmayan.',
    confident: true,
  ),
  profile: api.ProfileScores(
    openness: 0.5,
    conscientiousness: 0.5,
    extraversion: 0.5,
    agreeableness: 0.5,
    neuroticism: 0.5,
  ),
  claimedAt: DateTime(2026, 8, 30),
);

void main() {
  late _MockResults results;
  late _MockEntitlements entitlements;
  late _MockTurns turns;

  setUp(() {
    results = _MockResults();
    entitlements = _MockEntitlements();
    turns = _MockTurns();

    when(
      () => results.resultHistory(),
    ).thenAnswer((_) async => api.ResultHistory(results: [_summary()]));
    when(() => entitlements.currentEntitlement()).thenAnswer(
      (_) async => api.EntitlementResponse(
        remainingUses: 1,
        skipsLeft: 1,
        premium: false,
      ),
    );
  });

  Future<void> pump(WidgetTester tester, {required int remaining}) async {
    when(() => turns.gameTurns(today: any(named: 'today'))).thenAnswer(
      (_) async => api.PlayCredits(
        remaining: remaining,
        earned: remaining,
        spent: 0,
        dayMarked: true,
        tasksDone: true,
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProfileCubit(results, entitlements)..unawaitedLoad(),
          ),
          BlocProvider(
            create: (_) => TurnsCubit(TurnsRepository(turns))..unawaitedLoad(),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the profile', () {
    testWidgets('does not say the archetype a second time', (tester) async {
      await pump(tester, remaining: 1);

      // Bugün opens with the archetype, in the card and in the row under it.
      // Saying it again here made this screen read as a copy of that one.
      expect(find.text('ŞU ANKİ ARKETİPİN'), findsNothing);
      expect(find.text('Sessiz İnşacı'), findsNothing);
      expect(find.text('Geçmiş sonuçların'), findsOneWidget);
    });

    testWidgets('offers the game only while there is a turn', (tester) async {
      await pump(tester, remaining: 1);
      expect(find.text('Oyun'), findsOneWidget);
    });

    testWidgets('hides the game when there is none', (tester) async {
      await pump(tester, remaining: 0);

      // A row that answers a tap with "you have none" is worse than a row that
      // was not there.
      expect(find.text('Oyun'), findsNothing);
      expect(find.text('Geçmiş sonuçların'), findsOneWidget);
    });

    testWidgets('keeps settings in the bar, not in the list', (tester) async {
      await pump(tester, remaining: 1);

      // A row made settings look like one of the things somebody came to this
      // screen to read.
      expect(find.widgetWithText(ListTile, 'Ayarlar'), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });
}
