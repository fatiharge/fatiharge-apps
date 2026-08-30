import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/presentation/widgets/chain_strip.dart';

void main() {
  Widget strip(Chain chain, DateTime today) => MaterialApp(
    home: Scaffold(
      body: ChainStrip(chain: chain, today: today, streak: 0),
    ),
  );

  testWidgets('the number counts what the boxes count', (tester) async {
    final start = DateTime(2026, 8, 25);
    // Day five of the run, with two of those days marked. The number used to
    // be which day you were on, so this read "5 / 14" over two filled boxes.
    await tester.pumpWidget(
      strip(
        Chain(
          startedOn: start,
          markedDays: {start, DateTime(2026, 8, 26)},
        ),
        DateTime(2026, 8, 29),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text(' / 14'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('a chain that has not started counts nothing', (tester) async {
    await tester.pumpWidget(strip(const Chain(), DateTime(2026, 8, 29)));

    expect(find.text('0'), findsOneWidget);
  });
}
