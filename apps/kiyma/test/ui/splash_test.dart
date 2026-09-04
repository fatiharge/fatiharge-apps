import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    double progress, {
    Duration hold = const Duration(seconds: 3),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashView(progress: progress, hold: hold),
      ),
    );
    await tester.pump();
  }

  double barValue(WidgetTester tester) => tester
      .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .value!;

  testWidgets('carries the wordmark, the badge and the studio line', (
    tester,
  ) async {
    await show(tester, 0.4);

    expect(find.text('KIYMA'), findsOneWidget);
    expect(find.text('OCAKBAŞI SİMÜLATÖRÜ'), findsOneWidget);
    expect(find.text('ATEŞ USTASI, KEBAP SANATI'), findsOneWidget);
    expect(find.text('dafalabs'), findsOneWidget);
    // Two flames, one either side of the badge.
    expect(find.byIcon(Icons.local_fire_department), findsNWidgets(2));
  });

  testWidgets('the wordmark is Rubik in the ember colour, outlined', (
    tester,
  ) async {
    await show(tester, 0);
    final style = tester.widget<Text>(find.text('KIYMA')).style!;

    expect(style.fontFamily, 'Rubik');
    expect(style.color, KiymaPalette.ates);
    // Eight offsets make the outline, one the extrusion, one the cast shadow.
    expect(style.shadows, hasLength(10));
  });

  testWidgets('shows how far startup has got', (tester) async {
    await show(tester, 0.5);
    expect(barValue(tester), 0.5);
  });

  testWidgets('the bar keeps moving after the jobs are done', (tester) async {
    // Everything loaded at once; only the hold is left to wait out.
    await show(tester, 1);
    expect(barValue(tester), 1);

    await show(tester, 0, hold: const Duration(seconds: 4));
    expect(barValue(tester), 0);
    await tester.pump(const Duration(seconds: 2));
    expect(barValue(tester), greaterThan(0.3));
    await tester.pump(const Duration(seconds: 2));
    expect(barValue(tester), 1);
  });

  testWidgets('real progress wins when it is ahead of the clock', (
    tester,
  ) async {
    await show(tester, 0.8, hold: const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 100));
    expect(barValue(tester), 0.8);
  });

  testWidgets('the animation stops with the screen', (tester) async {
    await show(tester, 0.2);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });
}
