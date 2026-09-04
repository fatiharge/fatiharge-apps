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

  testWidgets('carries the wordmark and the studio line, and no words', (
    tester,
  ) async {
    await show(tester, 0.4);

    expect(find.text('KIYMA'), findsOneWidget);
    expect(find.text('dafalabs'), findsOneWidget);
    // Nothing translated: this runs before anybody has chosen a language.
    expect(find.byType(Text), findsNWidgets(2));
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

  testWidgets('the bar measures the whole wait, not just the jobs', (
    tester,
  ) async {
    // What actually happens: everything loads in under 100 ms and the rest of
    // the three seconds is the brand hold. The bar has to spend that time
    // moving, or it fills in the first frames and then looks broken.
    await show(tester, 1, hold: const Duration(seconds: 4));
    expect(barValue(tester), 0);

    await tester.pump(const Duration(seconds: 2));
    expect(barValue(tester), closeTo(0.5, 0.05));
    await tester.pump(const Duration(seconds: 2));
    expect(barValue(tester), 1);
  });

  testWidgets('and it cannot finish while a job is still running', (
    tester,
  ) async {
    // The other direction: a slow load holds the bar back however long the
    // clock has been running.
    await show(tester, 0.5, hold: const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 1));
    expect(barValue(tester), 0.5);
  });

  testWidgets('the animation stops with the screen', (tester) async {
    await show(tester, 0.2);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });
}
