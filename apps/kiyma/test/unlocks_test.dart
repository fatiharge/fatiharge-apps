import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/unlocks.dart';

void main() {
  test('a ladder opens one rung at a time, from the bottom', () {
    final unlocks = Unlocks();
    final komur = Unlocks.kademeler(UnlockGroup.komur);
    expect(komur.map((u) => u.kademe), [1, 2, 3, 4, 5]);

    expect(unlocks.available(komur[0]), isTrue);
    expect(unlocks.available(komur[1]), isFalse, reason: 'no skipping');

    unlocks.open(komur[0].id);
    expect(unlocks.kademe(UnlockGroup.komur), 1);
    expect(unlocks.available(komur[1]), isTrue);
  });

  test('a group behind a lock sells nothing until it is open', () {
    final unlocks = Unlocks();
    expect(unlocks.grupAcik(UnlockGroup.ayranSurahisi), isFalse);
    expect(
      unlocks.forSale.map((u) => u.grup),
      isNot(contains(UnlockGroup.ayranSurahisi)),
    );

    unlocks
      ..open('icecek_hatti')
      ..open('icecek_ayran');
    expect(unlocks.grupAcik(UnlockGroup.ayranSurahisi), isTrue);
    expect(unlocks.forSale.map((u) => u.id), contains('surahi_ayran_1'));
  });

  test('each jug climbs on its own', () {
    final unlocks = Unlocks()
      ..open('icecek_hatti')
      ..open('icecek_ayran')
      ..open('surahi_ayran_1')
      ..open('surahi_ayran_2');
    expect(unlocks.surahiKademesi(Drink.ayran), 2);
    expect(unlocks.surahiKademesi(Drink.salgam), 0);
    // Cola is bottled: there is no jug to widen.
    expect(unlocks.surahiKademesi(Drink.kola), 0);
  });

  test('the caps the counter was built for hold', () {
    final unlocks = Unlocks();
    for (final unlock in Unlocks.catalogue) {
      unlocks.open(unlock.id);
    }
    expect(unlocks.mangalSlots, 4, reason: 'four skewers, never five');
    expect(unlocks.musteriSlots, 3, reason: 'three places at the counter');
    expect(unlocks.bekleme, 3);
    expect(unlocks.bardakGozu, 3);
    // The knife stops at one handful: an ingredient that goes on in a single
    // touch is a tray again, not a build.
    expect(unlocks.tutamAdedi, 1);
  });

  test('a rung is restored whatever order the save is read in', () {
    final unlocks = Unlocks();
    // Written newest-first, which a Set makes no promises about.
    ['komur_3', 'komur_1', 'komur_2'].forEach(unlocks.open);
    expect(unlocks.kademe(UnlockGroup.komur), 3);
  });

  test('the shop is half of everything the game ever pays', () {
    final total = Unlocks.catalogue.fold(0, (sum, u) => sum + u.price);
    final son = Balance.targets.length;
    expect(total, lessThan(Balance.target(son)));
    expect(total, greaterThan(Balance.target(son) * 0.4));
    // Every rung costs more than the one under it, so a ladder is a climb
    // rather than a list. The two lines are the exception: opening the plate
    // or the drinks line is the big purchase and the things that go on it
    // afterwards are small, which is the shape those two should have.
    const hatlar = {UnlockGroup.porsiyon, UnlockGroup.icecek};
    for (final grup in UnlockGroup.values) {
      final rungs = Unlocks.kademeler(grup);
      for (var i = hatlar.contains(grup) ? 2 : 1; i < rungs.length; i++) {
        expect(
          rungs[i].price,
          greaterThan(rungs[i - 1].price),
          reason: '${grup.id} rung ${i + 1}',
        );
      }
    }
  });
}
