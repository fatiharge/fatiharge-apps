import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/ui/panels.dart';

KiymaState state({
  GamePhase phase = GamePhase.gunBasi,
  int gun = 1,
  int para = 0,
  int toplamKazanc = 0,
  int hedef = 70,
  bool gunGecildi = false,
}) => KiymaState(
  phase: phase,
  gun: gun,
  para: para,
  toplamKazanc: toplamKazanc,
  hedef: hedef,
  itibar: Balance.startingReputation,
  kalanMusteri: 0,
  gunGecildi: gunGecildi,
);

Future<void> show(WidgetTester tester, Widget panel) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: panel)));

void main() {
  group('the day-start card', () {
    testWidgets('names the day and the cumulative target', (tester) async {
      var started = false;
      await show(
        tester,
        DayStartPanel(
          state: state(gun: 3, hedef: 295, toplamKazanc: 180),
          onStart: () => started = true,
        ),
      );

      expect(find.text('Gün 3'), findsOneWidget);
      expect(find.text('Kümülatif hedef ₺295'), findsOneWidget);
      expect(find.text('Şu ana kadar ₺180'), findsOneWidget);

      await tester.tap(find.text('Tezgahı aç'));
      expect(started, isTrue);
    });
  });

  group('the day-end card', () {
    testWidgets('says the day was cleared and nothing about a replay', (
      tester,
    ) async {
      await show(
        tester,
        DayEndPanel(
          state: state(toplamKazanc: 90, gunGecildi: true),
          onContinue: () {},
        ),
      );
      expect(find.text('Gün geçildi'), findsOneWidget);
      expect(find.text('Toplam kazanç ₺90 / ₺70'), findsOneWidget);
      expect(find.textContaining('Gün tekrar'), findsNothing);
    });

    testWidgets('promises the money stays when the target was missed', (
      tester,
    ) async {
      var continued = false;
      await show(
        tester,
        DayEndPanel(
          state: state(toplamKazanc: 40),
          onContinue: () => continued = true,
        ),
      );
      expect(find.text('Hedef tutmadı'), findsOneWidget);
      expect(find.textContaining('kazandığın para kalır'), findsOneWidget);

      await tester.tap(find.text('Devam'));
      expect(continued, isTrue);
    });
  });

  group('the shop', () {
    testWidgets('sells what there is money for and nothing else', (
      tester,
    ) async {
      Unlock? bought;
      await show(
        tester,
        ShopPanel(
          state: state(phase: GamePhase.magaza, para: 200),
          unlocks: Unlocks(),
          onBuy: (unlock) => bought = unlock,
          onClose: () {},
        ),
      );

      expect(find.text('Kasada ₺200'), findsOneWidget);
      expect(find.text('Biber'), findsOneWidget);

      final pepper = find.widgetWithText(TextButton, '₺150');
      final pickles = find.widgetWithText(TextButton, '₺250');
      expect(tester.widget<TextButton>(pepper).onPressed, isNotNull);
      expect(tester.widget<TextButton>(pickles).onPressed, isNull);

      await tester.tap(pepper);
      expect(bought?.id, 'malzeme_biber');
    });

    testWidgets('hides what is not reachable yet', (tester) async {
      await show(
        tester,
        ShopPanel(
          state: state(phase: GamePhase.magaza, para: 9999),
          unlocks: Unlocks(),
          onBuy: (_) {},
          onClose: () {},
        ),
      );
      expect(find.text('4. mangal slotu'), findsNothing);
      expect(find.text('Ezme'), findsNothing);
    });

    testWidgets('says so when there is nothing left to buy', (tester) async {
      final unlocks = Unlocks();
      for (final unlock in Unlocks.catalogue) {
        unlocks.open(unlock.id);
      }
      var closed = false;
      await show(
        tester,
        ShopPanel(
          state: state(phase: GamePhase.magaza),
          unlocks: unlocks,
          onBuy: (_) {},
          onClose: () => closed = true,
        ),
      );
      expect(find.text('Şimdilik alınacak bir şey yok.'), findsOneWidget);

      await tester.tap(find.text('Sonraki güne geç'));
      expect(closed, isTrue);
    });
  });
}
