import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/splash.dart';

void main() {
  testWidgets('the HUD carries the till and nothing else', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Hud(
          onPause: () {},
          state: const KiymaState(
            gun: 7,
            para: 120,
            xp: 900,
            seviyeTabani: 865,
            hedef: 1125,
            oturum: null,
            gunBitti: false,
            duraklatildi: false,
          ),
        ),
      ),
    );

    expect(find.text('₺120'), findsOneWidget);
    // The level and the day belong between runs, not over the counter.
    expect(find.textContaining('7'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('the splash shows how far startup has got', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView(progress: 0.5)));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
