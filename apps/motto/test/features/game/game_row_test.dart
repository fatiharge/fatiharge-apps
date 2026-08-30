import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/game/presentation/widgets/game_row.dart';

ChainState _chain({Set<DateTime> marked = const {}}) => ChainState(
  chain: Chain(startedOn: DateTime(2026, 8, 20), markedDays: marked),
);

void main() {
  final today = DateTime(2026, 8, 30);

  group('the way into the game beside the day', () {
    test('is not there until the day is marked', () {
      // The game is not what somebody opens this app to do, and a permanent
      // invitation under the day's three things is a second thing asking to
      // be done.
      expect(GameRow.forDay(_chain(), today, any: true), isNull);
    });

    test('is there once it is', () {
      expect(
        GameRow.forDay(_chain(marked: {today}), today, any: true),
        isNotNull,
      );
    });

    test('does not follow yesterday into today', () {
      expect(
        GameRow.forDay(
          _chain(marked: {DateTime(2026, 8, 29)}),
          today,
          any: true,
        ),
        isNull,
      );
    });

    test('is not there when there is no turn to spend', () {
      // A card that answers a tap with "you have none" is worse than a card
      // that was not there.
      expect(
        GameRow.forDay(_chain(marked: {today}), today, any: false),
        isNull,
      );
    });

    testWidgets('says what a turn is worth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameRow.forDay(_chain(marked: {today}), today, any: true),
          ),
        ),
      );

      // Naming the reward is the point: the deep report being earnable is the
      // part nobody knew about.
      expect(find.text('BUGÜNÜ İŞARETLEDİN'), findsOneWidget);
      expect(
        find.text('Haftanın ilk 10 skoru bir derin rapor kazanıyor.'),
        findsOneWidget,
      );
    });
  });
}
