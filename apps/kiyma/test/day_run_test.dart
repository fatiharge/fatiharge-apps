import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/order.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  setUpAll(() async => scene = await SceneData.load());

  final events = <DayEvent>[];

  DayRun build({List<String> unlock = const []}) {
    events.clear();
    final progress = Progress();
    unlock.forEach(progress.unlocks.open);
    // Arrivals are tested on their own; every other test places the customer
    // it needs, so the queue is emptied to keep them out of the way.
    return DayRun(
      scene: scene,
      progress: progress,
      onEvent: events.add,
      onChanged: () {},
      random: math.Random(7),
    )..kuyruk = 0;
  }

  Offset at(String region) => scene[region].quad.center;
  Offset slot(String region, int index) => scene[region].slots[index].center;

  bool drag(DayRun run, Offset from, Offset to) {
    if (!run.beginDrag(from)) return false;
    run
      ..carriedAt = to
      ..endDrag(to);
    return true;
  }

  /// Runs the grill clock without letting the day-end check fire.
  void cook(DayRun run, double seconds) {
    for (var t = 0.0; t < seconds; t += 0.1) {
      for (final slot in run.mangal) {
        slot.tick(0.1, run.day);
      }
    }
  }

  Customer waiting(DayRun run, Order order, {int slot = 0}) {
    final customer = Customer(order: order, day: run.day);
    run.musteriler[slot] = customer;
    return customer;
  }

  Order wrapFor(Set<String> ister, {Set<String> istemez = const {}}) =>
      Order(tip: UrunTipi.durum, ister: ister, istemez: istemez);

  /// Lavash, cooked meat, then whatever ingredients were asked for.
  void buildWrap(DayRun run, {Set<Malzeme> malzemeler = const {}}) {
    expect(drag(run, at('lavas_kaynak'), at('durum_hazirlama')), isTrue);
    expect(drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0)), isTrue);
    cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);
    expect(run.mangal[0].durum, Pisme.pismis);
    expect(
      drag(run, slot('mangal_alani', 0), at('durum_hazirlama')),
      isTrue,
    );
    for (final malzeme in malzemeler) {
      expect(drag(run, at(malzeme.region), at('durum_hazirlama')), isTrue);
    }
  }

  group('the wrap line', () {
    test('goes bread, meat, ingredients, roll, paper, service', () {
      final run = build();
      final customer = waiting(run, wrapFor({'domates'}));

      buildWrap(run, malzemeler: {Malzeme.domates});
      final station = run.durumIstasyonu!;
      expect(station.etli, isTrue);
      expect(station.malzemeler, {Malzeme.domates});

      // Paper before the roll is not a step (design doc 3.1).
      expect(drag(run, at('kagit_kaynak'), at('durum_hazirlama')), isTrue);
      expect(station.kagitli, isFalse);

      run.flickUp(at('durum_hazirlama'));
      expect(station.sarili, isTrue);
      expect(drag(run, at('kagit_kaynak'), at('durum_hazirlama')), isTrue);
      expect(station.kagitli, isTrue);

      expect(drag(run, at('durum_hazirlama'), at('musteri_slot_1')), isTrue);
      expect(run.durumIstasyonu, isNull);
      expect(run.musteriler[0], isNull, reason: 'the customer left happy');
      expect(customer.anaUrunVerildi, isTrue);

      // 10 * 1.08 rounded, plus one ingredient at the flat bonus.
      expect(run.progress.para, 13);
      expect(run.progress.itibar, Balance.startingReputation + 1);
    });

    test('will not take an ingredient before the meat', () {
      final run = build();
      expect(drag(run, at('lavas_kaynak'), at('durum_hazirlama')), isTrue);
      expect(
        drag(run, at('malzeme_domates'), at('durum_hazirlama')),
        isTrue,
        reason: 'the drag happens; the drop is what is refused',
      );
      expect(run.durumIstasyonu!.malzemeler, isEmpty);
      expect(events, contains(DayEvent.gecersiz));
    });

    test('will not take an ingredient after the roll', () {
      final run = build();
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('malzeme_domates'), at('durum_hazirlama'));
      expect(run.durumIstasyonu!.malzemeler, isEmpty);
    });

    test('takes the same ingredient only once', () {
      final run = build();
      buildWrap(run, malzemeler: {Malzeme.domates});
      drag(run, at('malzeme_domates'), at('durum_hazirlama'));
      expect(run.durumIstasyonu!.malzemeler, hasLength(1));
    });

    test('locked ingredients cannot be picked up at all', () {
      final run = build();
      expect(run.beginDrag(at('malzeme_biber')), isFalse);
      expect(run.beginDrag(at('malzeme_tursu')), isFalse);
    });
  });

  group('the grill', () {
    test('runs raw, cooking, cooked, burnt on the design doc clock', () {
      final slot = MangalSlot()..koy();
      expect(slot.durum, Pisme.cig);
      expect(slot.alinabilir, isFalse);

      slot.tick(Balance.rawSeconds + 0.01, 1);
      expect(slot.durum, Pisme.pisiyor);
      expect(slot.alinabilir, isFalse);

      slot.tick(Balance.cookingSeconds, 1);
      expect(slot.durum, Pisme.pismis);
      expect(slot.alinabilir, isTrue);

      final burned = slot.tick(Balance.cookedWindow(1), 1);
      expect(slot.durum, Pisme.yanmis);
      expect(burned, isTrue, reason: 'reported once, on the frame it burns');
      expect(slot.tick(1, 1), isFalse, reason: 'and never again');
    });

    test('burning costs money and blocks the slot until it is binned', () {
      final run = build();
      run.progress.kazan(100);
      waiting(run, wrapFor(const {}));

      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      run
        ..tick(Balance.rawSeconds + Balance.cookingSeconds + 0.1)
        ..tick(Balance.cookedWindow(run.day) + 0.1);

      expect(run.mangal[0].yanmis, isTrue);
      expect(events, contains(DayEvent.yandi));
      expect(run.progress.para, 100 - Balance.burnPenalty(1).round());

      // Blocked: no fresh meat goes in while the burnt skewer is there.
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      expect(run.mangal[0].yanmis, isTrue);

      expect(drag(run, slot('mangal_alani', 0), at('cop_alani')), isTrue);
      expect(run.mangal[0].bos, isTrue);
    });

    test('burnt meat goes nowhere but the bin', () {
      final run = build();
      waiting(run, wrapFor(const {}));
      drag(run, at('lavas_kaynak'), at('durum_hazirlama'));
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      cook(run, 20);
      expect(run.mangal[0].yanmis, isTrue);

      drag(run, slot('mangal_alani', 0), at('durum_hazirlama'));
      expect(run.durumIstasyonu!.etli, isFalse);
      expect(run.mangal[0].yanmis, isTrue);
    });

    test('locked slots refuse meat', () {
      final run = build();
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 3));
      expect(run.mangal[3].bos, isTrue);
    });
  });

  group('the customer', () {
    test('refuses a wrap carrying something on the avoid list', () {
      final run = build();
      final customer = waiting(
        run,
        wrapFor({'domates'}, istemez: {'sogan'}),
      );
      buildWrap(run, malzemeler: {Malzeme.domates, Malzeme.sogan});
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));

      drag(run, at('durum_hazirlama'), at('musteri_slot_1'));
      expect(events, contains(DayEvent.reddedildi));
      expect(run.progress.para, 0);
      // A fifth of what was left, not of the maximum (design doc 8.4).
      expect(
        customer.sabirKalan,
        closeTo(customer.sabirToplam * Balance.refusalKeeps, 0.001),
      );
      // And the wrap is on its shelf, not lost.
      expect(run.durumIstasyonu, isNull);
      expect(run.durumBekleme.first, isNotNull);
    });

    test('a refused wrap blocks the prep area when the shelf is full', () {
      final run = build();
      waiting(run, wrapFor({'sogan'}));
      buildWrap(run, malzemeler: {Malzeme.domates});
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));

      // One shelf slot is open on day one, and something is already on it.
      run.durumBekleme[0] = DurumUrun(Durum());
      drag(run, at('durum_hazirlama'), at('musteri_slot_1'));
      expect(run.durumIstasyonu, isNotNull, reason: 'stuck in the prep area');
    });

    test('pays for what it got and costs half the reputation on partial', () {
      final run = build(unlock: ['tatli_baklava']);
      final customer = waiting(
        run,
        Order(
          tip: UrunTipi.durum,
          ister: const {},
          istemez: const {},
          tatli: Tatli.baklava,
        ),
      );

      expect(drag(run, at('tatli_baklava'), at('musteri_slot_1')), isTrue);
      expect(customer.tatliVerildi, isTrue);
      expect(
        run.progress.para,
        Balance.income(Balance.tatliBase[Tatli.baklava]!, 1),
      );
      expect(run.musteriler[0], isNotNull, reason: 'the wrap is still owed');

      customer.sabirKalan = 0.05;
      run.tick(0.1);
      expect(run.musteriler[0], isNull);
      expect(
        run.progress.itibar,
        Balance.startingReputation + Balance.reputationPartial,
      );
    });

    test('costs the full reputation when it gets nothing', () {
      final run = build();
      waiting(run, wrapFor(const {})).sabirKalan = 0.05;
      run.tick(0.1);
      expect(
        run.progress.itibar,
        Balance.startingReputation + Balance.reputationNothing,
      );
      expect(events, contains(DayEvent.musteriKizgin));
    });

    test('reputation never falls through the floor', () {
      final run = build();
      run.progress.itibar = Balance.reputationFloor + 2;
      waiting(run, wrapFor(const {})).sabirKalan = 0.05;
      run.tick(0.1);
      expect(run.progress.itibar, Balance.reputationFloor);
    });
  });

  group('the plate line', () {
    test('needs the flatbread first and never rolls', () {
      final run = build(unlock: ['porsiyon_hatti', 'bilesen_ezme']);
      waiting(run, wrapFor(const {}));

      run.tap(at('tabak_kaynak'));
      expect(run.tabakIstasyonu, isNotNull);

      // Meat on a bare plate is refused; bread has to go down first.
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      cook(run, 6.2);
      drag(run, slot('mangal_alani', 0), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.etli, isFalse);

      drag(run, at('lavas_kaynak'), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.lavasli, isTrue);
      drag(run, slot('mangal_alani', 0), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.etli, isTrue);
      expect(run.tabakIstasyonu!.hazir, isTrue, reason: 'no roll, no paper');

      drag(run, at('malzeme_ezme'), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.bilesenler, {Bilesen.ezme});
    });

    test('wrap ingredients do not go on a plate, and the reverse', () {
      final run = build(unlock: ['porsiyon_hatti', 'bilesen_ezme'])
        ..tap(at('tabak_kaynak'));
      drag(run, at('lavas_kaynak'), at('tabak_hazirlama'));
      drag(run, at('malzeme_domates'), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.bilesenler, isEmpty);

      drag(run, at('lavas_kaynak'), at('durum_hazirlama'));
      drag(run, at('malzeme_ezme'), at('durum_hazirlama'));
      expect(run.durumIstasyonu!.malzemeler, isEmpty);
    });

    test('is not there before it is bought', () {
      final run = build()..tap(at('tabak_kaynak'));
      expect(run.tabakIstasyonu, isNull);
      expect(events, contains(DayEvent.gecersiz));
    });
  });

  group('the drinks line', () {
    test('tap for a glass, drag the jug, then serve', () {
      final run = build(unlock: ['icecek_hatti', 'icecek_ayran']);
      final customer = waiting(
        run,
        Order(
          tip: UrunTipi.durum,
          ister: const {},
          istemez: const {},
          icecek: Icecek.ayran,
        ),
      );

      run.tap(at('bardak_kaynak'));
      final bardak = run.bardakBekletme[0]!;
      expect(bardak.bos, isTrue);

      expect(
        drag(run, at('surahi_ayran'), slot('bardak_bekletme', 0)),
        isTrue,
      );
      expect(bardak.doluyor, isTrue);
      // Locked while it fills: nothing leaves the shelf half full.
      expect(run.beginDrag(slot('bardak_bekletme', 0)), isFalse);

      bardak.tick(Balance.pourSeconds);
      expect(bardak.hazir, isTrue);
      expect(bardak.icerik, Icecek.ayran);

      expect(
        drag(run, slot('bardak_bekletme', 0), at('musteri_slot_1')),
        isTrue,
      );
      expect(customer.icecekVerildi, isTrue);
      expect(run.bardakBekletme[0], isNull);
    });

    test('cola is a bottle and needs no glass', () {
      final run = build(unlock: ['icecek_hatti', 'icecek_kola']);
      final customer = waiting(
        run,
        Order(
          tip: UrunTipi.durum,
          ister: const {},
          istemez: const {},
          icecek: Icecek.kola,
        ),
      );
      expect(drag(run, at('kola_kaynak'), at('musteri_slot_1')), isTrue);
      expect(customer.icecekVerildi, isTrue);
    });
  });

  group('the day', () {
    test('ends once the queue and the counter are both empty', () {
      final run = build()..tick(0.1);
      expect(run.bitti, isTrue);
      expect(events, contains(DayEvent.gunBitti));
    });

    test('seats arrivals only in the places that are open', () {
      final run = build()..kuyruk = 4;
      for (var i = 0; i < 40; i++) {
        run.tick(0.5);
      }
      expect(run.musteriler[0], isNotNull);
      expect(run.musteriler[1], isNotNull);
      expect(run.musteriler[2], isNull);
      expect(run.musteriler[3], isNull);
    });

    test('does nothing once it is over', () {
      final run = build()..tick(0.1);
      expect(run.beginDrag(at('lavas_kaynak')), isFalse);
      run.tap(at('tabak_kaynak'));
      expect(run.tabakIstasyonu, isNull);
    });
  });

  group('the bin', () {
    test('takes anything and clears the prep area', () {
      final run = build();
      waiting(run, wrapFor(const {}));
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));
      expect(drag(run, at('durum_hazirlama'), at('cop_alani')), isTrue);
      expect(run.durumIstasyonu, isNull);
    });
  });
}
