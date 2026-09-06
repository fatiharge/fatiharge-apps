import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_rule.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/order_maker.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/domain/unlocks.dart';

void main() {
  test('the first days carry no rule at all', () {
    for (var day = 1; day < Balance.ilkKuralGunu; day++) {
      expect(DayRule.forDay(day).adsiz, isTrue, reason: 'day $day');
    }
    expect(DayRule.forDay(Balance.ilkKuralGunu).adsiz, isFalse);
  });

  test('a day always gets the same rule, so the card can promise it', () {
    for (var day = 1; day < 30; day++) {
      expect(DayRule.forDay(day).id, DayRule.forDay(day).id);
    }
  });

  test('nothing neutral is left to chance', () {
    // The identity has to stay the identity: every modifier the run applies
    // unconditionally is only safe because of this.
    const yok = DayRule.yok;
    expect(yok.odeme, 1);
    expect(yok.pencereCarpani, 1);
    expect(yok.mangalKesintisi, 0);
    expect(yok.ekMalzeme, 0);
    expect(yok.sadeDurum, isFalse);
    expect(yok.bagislanan, Tempo.bagislanan);
    expect(yok.tatliSansi, Balance.tatliSansi);
  });

  test('wraps only closes the plate line, however much is bought', () {
    final unlocks = Unlocks()
      ..open('porsiyon_hatti')
      ..open('bilesen_icli_kofte');
    final maker = OrderMaker(
      unlocks,
      day: 6,
      kural: DayRule.durumGunu,
      random: math.Random(2),
    );
    for (var i = 0; i < 200; i++) {
      expect(maker.make().tip, ProductKind.durum);
    }
  });

  test('a fussy day asks for more than an ordinary one', () {
    final unlocks = Unlocks()
      ..open('malzeme_biber')
      ..open('malzeme_tursu');
    int asks(DayRule kural) {
      final maker = OrderMaker(
        unlocks,
        day: 6,
        kural: kural,
        random: math.Random(9),
      );
      var total = 0;
      for (var i = 0; i < 300; i++) {
        final order = maker.make();
        total += order.ister.length + order.istemez.length;
      }
      return total;
    }

    expect(asks(DayRule.titizGun), greaterThan(asks(DayRule.yok)));
  });

  test('an inspection forgives nothing', () {
    final tempo = Tempo(bagislananSayisi: DayRule.denetim.bagislanan);
    final before = tempo.deger;
    tempo.gecersizHareket();
    // The first mis-drop already costs the graded penalty, not the token one.
    expect(before - tempo.deger, greaterThan(-Tempo.hataDokunusu));
  });

  test('a holiday means everybody, and no rule ever empties the grill', () {
    expect(DayRule.bayram.tatliSansi, 1);
    for (final kural in DayRule.dongu) {
      expect(kural.mangalKesintisi, lessThanOrEqualTo(1));
    }
    expect(Balance.enAzMangal, 2);
  });

  test('the goal is reachable and pays a share of the day', () {
    for (var day = 1; day <= 12; day++) {
      // The count grows with the day because the day gets longer; what is
      // capped is the rate it asks for.
      expect(
        Balance.hedefTempo(day),
        lessThanOrEqualTo(Balance.gunlukHedefTavan),
      );
      expect(Balance.gunlukOdul(day), greaterThan(0));
      // Worth having, never worth more than the day itself.
      expect(
        Balance.gunlukOdul(day),
        lessThan(Balance.target(day) - Balance.floor(day)),
      );
    }
  });
}
