import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/musteri_tipi.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/order_maker.dart';
import 'package:kiyma/domain/unlocks.dart';

void main() {
  Set<MusteriTipi> typesOver(int day, {Unlocks? unlocks}) {
    final maker = OrderMaker(
      unlocks ?? Unlocks(),
      day: day,
      random: math.Random(7),
    );
    return {for (var i = 0; i < 400; i++) maker.make().musteriTipi};
  }

  test('the early days are plain, and nothing turns up before its day', () {
    expect(typesOver(1), {MusteriTipi.siradan});
    expect(typesOver(2), {MusteriTipi.siradan});
    expect(typesOver(3), contains(MusteriTipi.aceleci));
    expect(typesOver(3), isNot(contains(MusteriTipi.titiz)));
  });

  test('a big order waits for the plate line, whatever day it is', () {
    // Day nine is well past kalabalik's day, and it still cannot appear:
    // two wraps is the same job twice.
    expect(typesOver(9), isNot(contains(MusteriTipi.kalabalik)));

    final open = Unlocks()
      ..open('porsiyon_hatti')
      ..open('bilesen_ezme');
    expect(typesOver(9, unlocks: open), contains(MusteriTipi.kalabalik));
  });

  test('a big order is two products, and they are different lines', () {
    final open = Unlocks()
      ..open('porsiyon_hatti')
      ..open('bilesen_ezme');
    final maker = OrderMaker(open, day: 9, random: math.Random(3));
    var seen = 0;
    for (var i = 0; i < 500; i++) {
      final order = maker.make();
      if (order.musteriTipi != MusteriTipi.kalabalik) continue;
      seen++;
      expect(order.ikinci, isNotNull);
      expect(order.ikinci!.tip, isNot(order.tip));
      // One ticket, one dessert, one drink.
      expect(order.ikinci!.ikinci, isNull);
      expect(order.ikinci!.tatli, isNull);
      expect(order.ikinci!.icecek, isNull);
    }
    expect(seen, greaterThan(0));
  });

  test('a fussy customer names two things they will not have', () {
    final open = Unlocks()
      ..open('malzeme_biber')
      ..open('malzeme_tursu');
    final maker = OrderMaker(open, day: 6, random: math.Random(11));
    var seen = 0;
    for (var i = 0; i < 500; i++) {
      final order = maker.make();
      if (order.musteriTipi != MusteriTipi.titiz) continue;
      seen++;
      expect(order.istemez.length, greaterThanOrEqualTo(Balance.titizIstemez));
      // Never out of what they asked for.
      expect(order.ister.intersection(order.istemez), isEmpty);
    }
    expect(seen, greaterThan(0));
  });

  test('the hurried pay for the time they take away', () {
    expect(MusteriTipi.aceleci.odemeCarpani, greaterThan(1));
    expect(MusteriTipi.titiz.odemeCarpani, greaterThan(1));
    expect(MusteriTipi.siradan.odemeCarpani, 1);
    // The trade has to be worth taking: less time for the same money is
    // just a worse customer.
    expect(Balance.aceleciSabir, lessThan(1));
    expect(Balance.aceleciOdeme, greaterThan(1 / Balance.aceleciSabir * 0.5));
  });

  test('changing your mind swaps one ask for another, never for a ban', () {
    final order = Order(
      tip: UrunTipi.durum,
      ister: {'domates'},
      istemez: {'sogan'},
      musteriTipi: MusteriTipi.kararsiz,
    )..fikirDegistir('domates', 'sogan');

    expect(order.ister, {'sogan'});
    expect(order.istemez, isEmpty);
  });
}
