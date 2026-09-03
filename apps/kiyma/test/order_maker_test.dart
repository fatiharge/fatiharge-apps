import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/order_maker.dart';
import 'package:kiyma/game/unlocks.dart';

void main() {
  group('OrderMaker', () {
    test('never asks for anything the counter cannot make', () {
      final unlocks = Unlocks();
      final maker = OrderMaker(unlocks, random: math.Random(1));
      final open = unlocks.malzemeler.map((m) => m.id).toSet();

      for (var i = 0; i < 300; i++) {
        final order = maker.make();
        expect(order.tip, UrunTipi.durum, reason: 'the plate line is locked');
        expect(order.ister.union(order.istemez).difference(open), isEmpty);
        expect(order.tatli, isNull);
        expect(order.icecek, isNull);
      }
    });

    test('wants and avoids never overlap, and it always wants something', () {
      final unlocks = Unlocks();
      for (final unlock in Unlocks.catalogue) {
        unlocks.open(unlock.id);
      }
      final maker = OrderMaker(unlocks, random: math.Random(2));

      for (var i = 0; i < 300; i++) {
        final order = maker.make();
        expect(order.ister.intersection(order.istemez), isEmpty);
        expect(order.ister, isNotEmpty);
        expect(order.ister.length + order.istemez.length, lessThanOrEqualTo(3));
      }
    });

    test('asks for both lines once both are open', () {
      final unlocks = Unlocks()..open('porsiyon_hatti');
      final maker = OrderMaker(unlocks, random: math.Random(3));
      final tipler = {for (var i = 0; i < 40; i++) maker.make().tip};
      expect(tipler, UrunTipi.values.toSet());
    });

    test('a plate order only ever names plate components', () {
      final unlocks = Unlocks()
        ..open('porsiyon_hatti')
        ..open('bilesen_ezme')
        ..open('bilesen_pilav');
      final maker = OrderMaker(unlocks, random: math.Random(4));
      final plate = {Bilesen.ezme.id, Bilesen.pilav.id};

      for (var i = 0; i < 200; i++) {
        final order = maker.make();
        if (order.tip != UrunTipi.porsiyon) continue;
        expect(order.ister.union(order.istemez).difference(plate), isEmpty);
      }
    });
  });

  group('Unlocks', () {
    test('day one opens one line, two ingredients and two of everything', () {
      final unlocks = Unlocks();
      expect(unlocks.mangalSlots, 2);
      expect(unlocks.musteriSlots, 2);
      expect(unlocks.durumBekleme, 1);
      expect(unlocks.porsiyonBekleme, 0);
      expect(unlocks.malzemeler, {Malzeme.domates, Malzeme.sogan});
      expect(unlocks.porsiyonHatti, isFalse);
      expect(unlocks.icecekHatti, isFalse);
    });

    test('a fourth slot is not for sale before the third', () {
      final unlocks = Unlocks();
      expect(unlocks.forSale.map((u) => u.id), isNot(contains('mangal_4')));
      unlocks.open('mangal_3');
      expect(unlocks.forSale.map((u) => u.id), contains('mangal_4'));
    });

    test('a line has to be bought before anything on it', () {
      final unlocks = Unlocks();
      final locked = unlocks.forSale.map((u) => u.id);
      expect(locked, isNot(contains('bilesen_ezme')));
      expect(locked, isNot(contains('icecek_ayran')));
      unlocks
        ..open('porsiyon_hatti')
        ..open('icecek_hatti');
      final open = unlocks.forSale.map((u) => u.id);
      expect(open, contains('bilesen_ezme'));
      expect(open, contains('icecek_ayran'));
    });

    test('every lock has a name to show', () {
      expect(Unlocks.catalogue.map((u) => u.id).toSet(), hasLength(24));
    });
  });
}
