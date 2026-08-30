import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/days/presentation/widgets/period_grid.dart';

api.ChainPeriod _period({
  required int number,
  required int marked,
  bool current = false,
}) => api.ChainPeriod(
  period: number,
  current: current,
  days: [
    for (var i = 0; i < marked; i++)
      api.MarkedDay(day: DateTime(2026, 8, 10 + i), madeUp: false),
  ],
);

void main() {
  Future<void> pump(
    WidgetTester tester,
    api.ChainPeriod period, {
    void Function(int)? onDay,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PeriodGrid(period: period, onDay: onDay ?? (_) {}),
        ),
      ),
    );
  }

  group('a run of fourteen', () {
    testWidgets('draws every place, marked or not', (tester) async {
      await pump(tester, _period(number: 1, marked: 3));

      // Fourteen is the run, not the number of days somebody managed. A grid
      // that only draws what was done cannot show what is left.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('1. DÖNEM'), findsOneWidget);
      expect(find.textContaining('3 / 14'), findsOneWidget);
    });

    testWidgets('says which run is still going', (tester) async {
      await pump(tester, _period(number: 2, marked: 1, current: true));
      expect(find.textContaining('sürüyor'), findsOneWidget);
    });

    testWidgets('only a day that happened opens', (tester) async {
      final opened = <int>[];
      await pump(tester, _period(number: 1, marked: 2), onDay: opened.add);

      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump();

      // The position is what says which of the fourteen texts that day
      // carried, so an empty box has nothing behind it to open.
      expect(opened, [2]);
    });
  });
}
