import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';

void main() {
  Future<void> show(WidgetTester tester, double progress) async {
    await tester.pumpWidget(MaterialApp(home: SplashView(progress: progress)));
    await tester.pump();
  }

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
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.5,
    );
  });

  testWidgets('the animation stops with the screen', (tester) async {
    await show(tester, 0.2);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });
}
