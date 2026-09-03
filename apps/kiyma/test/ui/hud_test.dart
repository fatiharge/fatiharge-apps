import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';

void main() {
  testWidgets('the HUD shows money, the day, the target, standing and queue', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Hud(
          state: KiymaState(
            phase: GamePhase.oynaniyor,
            gun: 2,
            para: 120,
            toplamKazanc: 140,
            hedef: 170,
            itibar: 64,
            kalanMusteri: 5,
            gunGecildi: false,
          ),
        ),
      ),
    );

    expect(find.text('₺120'), findsOneWidget);
    expect(find.text('Gün 2'), findsOneWidget);
    expect(find.text('140/170'), findsOneWidget);
    expect(find.text('64'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(140 / 170, 0.001));
    expect(bar.valueColor!.value, KiymaPalette.kor);
  });

  testWidgets('a met target turns the bar green', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Hud(
          state: KiymaState(
            phase: GamePhase.oynaniyor,
            gun: 1,
            para: 90,
            toplamKazanc: 90,
            hedef: 70,
            itibar: 70,
            kalanMusteri: 1,
            gunGecildi: true,
          ),
        ),
      ),
    );
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 1);
    expect(bar.valueColor!.value, KiymaPalette.yesil);
  });

  testWidgets('the splash shows how far startup has got', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView(progress: 0.5)));
    expect(find.text('Kıyma'), findsOneWidget);
    expect(find.text('Tezgah kuruluyor'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.5,
    );
  });
}
