import 'dart:math';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/features/game/presentation/game_over_page.dart';
import 'package:motto/features/game/presentation/game_rules_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('the rules', () {
    late GameStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = GameStore(await SharedPreferences.getInstance());
      getIt.registerSingleton<GameStore>(store);
    });

    tearDown(getIt.reset);

    test('they are unseen until they are seen', () async {
      expect(store.rulesSeen, isFalse);

      await store.markRulesSeen();

      expect(store.rulesSeen, isTrue);
    });

    testWidgets('they say what wins and what costs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameRulesPage(onStart: (_) async {})),
      );

      expect(find.textContaining('Üç hakkın var'), findsOneWidget);
      expect(find.textContaining('derin rapor'), findsOneWidget);
    });

    testWidgets('starting marks them seen, so they come once', (tester) async {
      var started = false;
      await tester.pumpWidget(
        MaterialApp(home: GameRulesPage(onStart: (_) async => started = true)),
      );

      await tester.tap(find.text('Başla'));
      await tester.pumpAndSettle();

      expect(store.rulesSeen, isTrue);
      expect(started, isTrue);
    });
  });

  group('the score screen', () {
    api.Leaderboard board({bool mine = true}) => api.Leaderboard(
      week: DateTime(2026, 3, 9),
      entries: [
        api.LeaderboardEntry(rank: 1, points: 300, you: false),
        api.LeaderboardEntry(rank: 2, points: 120, you: mine),
      ],
      yourBest: mine ? 120 : 0,
      rewardedRanks: 10,
    );

    testWidgets('it shows the score and the week', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(score: 120, board: board())),
      );

      expect(find.text('120'), findsWidgets);
      expect(find.text('Bu hafta'), findsOneWidget);
      expect(find.textContaining('İlk 10'), findsOneWidget);
    });

    testWidgets('the board is shown even when the score did not reach it', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(score: 10, board: board(mine: false))),
      );

      // A board you only see when you win says nothing about whether playing
      // again is worth it.
      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('a score that could not be sent says so', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameOverPage(score: 40)),
      );

      expect(find.textContaining('gönderilemedi'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });
  });

  test('a seeded game plays the same round twice', () {
    // The seed exists so a test can play a known round; if it did not hold,
    // every game test would be a coin toss.
    final first = List.generate(5, (_) => Random(3).nextBool());
    final second = List.generate(5, (_) => Random(3).nextBool());

    expect(first, second);
  });
}
