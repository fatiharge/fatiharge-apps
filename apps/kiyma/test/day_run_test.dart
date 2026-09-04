import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/model/carried.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';

import 'support/scene_from_disk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  setUp(() => scene = sceneFromDisk());

  final events = <DayEvent>[];

  DayRun build({List<String> unlock = const []}) {
    events.clear();
    final progress = Progress();
    unlock.forEach(progress.unlocks.open);
    return DayRun(
      scene: scene,
      progress: progress,
      onEvent: events.add,
      onChanged: () {},
      random: math.Random(7),
    );
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

  /// A customer already standing at the counter. Tests that want the walk
  /// itself drive [DayRun.tick] instead.
  Customer waiting(DayRun run, Order order, {int slot = 0}) {
    final customer = Customer(order: order, day: run.day)..varis = 1;
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
      expect(
        run.durumIstasyonu,
        isNotNull,
        reason: 'it holds the prep area until it is carried off',
      );

      expect(drag(run, at('kagit_kaynak'), at('durum_hazirlama')), isTrue);
      expect(station.kagitli, isTrue);

      expect(drag(run, at('durum_hazirlama'), at('musteri_slot_1')), isTrue);
      expect(run.durumIstasyonu, isNull);
      expect(run.musteriler[0], isNull, reason: 'the customer left happy');
      expect(customer.anaUrunVerildi, isTrue);

      // 10 * 1.08 rounded, plus one ingredient at the flat bonus — left on
      // the ledge, not in the till.
      expect(run.altin[0]!.miktar, 13);
      run.tap(slot('altin_alani', 0));
      expect(run.progress.para, 13);
    });

    test('takes ingredients while the meat is still on the grill', () {
      final run = build();
      expect(drag(run, at('lavas_kaynak'), at('durum_hazirlama')), isTrue);
      expect(drag(run, at('malzeme_domates'), at('durum_hazirlama')), isTrue);
      expect(run.durumIstasyonu!.malzemeler, {Malzeme.domates});
      expect(events, isNot(contains(DayEvent.gecersiz)));

      // The meat is still what closes it: no skewer, no roll.
      expect(run.durumIstasyonu!.sarilabilir, isFalse);
      run.flickUp(at('durum_hazirlama'));
      expect(run.durumIstasyonu!.sarili, isFalse);
    });

    test('will not take an ingredient after the roll', () {
      final run = build();
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('malzeme_domates'), at('durum_hazirlama'));
      expect(run.durumIstasyonu!.malzemeler, isEmpty);
    });

    test('a finished wrap holds the prep area until it is carried off', () {
      final run = build();
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));

      final stuck = run.durumIstasyonu!;
      expect(stuck.hazir, isTrue);
      drag(run, at('lavas_kaynak'), at('durum_hazirlama'));
      expect(run.durumIstasyonu, same(stuck), reason: 'no room for the next');

      expect(
        drag(run, at('durum_hazirlama'), slot('bekleme_alani', 0)),
        isTrue,
      );
      expect(run.durumIstasyonu, isNull);
      expect(run.bekleme.first, isNotNull);
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

    test('burning costs money and holds the slot until it is binned', () {
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

      // The burnt skewer keeps its slot; fresh meat goes to another one.
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

    test('a locked slot passes the meat to an open one', () {
      final run = build();
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 3));
      expect(run.mangal[3].bos, isTrue, reason: 'slot 3 is not bought yet');
      expect(
        run.mangal[1].bos,
        isFalse,
        reason: 'the nearest open one took it',
      );
    });

    test('meat dropped on a full slot slides to the nearest free one', () {
      final run = build();
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      expect(run.mangal[0].bos, isFalse);

      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      expect(run.mangal[1].bos, isFalse);
    });

    test('a full grill refuses more meat', () {
      final run = build();
      for (var i = 0; i < 3; i++) {
        drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      }
      expect(run.mangal.where((slot) => !slot.bos), hasLength(2));
      // Named, not the generic refusal: the grill is the one area whose
      // "no" is invisible on the counter.
      expect(events, contains(DayEvent.mangalDolu));
      expect(run.parlama['mangal_alani']!.ok, isFalse);
    });

    test(
      'aiming anywhere on the grill picks the skewer nearest to burning',
      () {
        final run = build(unlock: ['mangal_3', 'mangal_4']);
        waiting(run, wrapFor(const {}));
        for (final index in [0, 1, 2]) {
          run.mangal[index].koy();
        }
        // Slot 1 went on first, so it is furthest through the cooked window.
        cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);
        run.mangal[1].tick(1.5, run.day);

        expect(run.mangal[3].bos, isTrue);
        final held = run.beginDrag(slot('mangal_alani', 3));
        expect(held, isTrue);
        expect((run.carried! as PismisEt).slot, 1);
      },
    );

    test('cooked is handed over before burnt', () {
      final run = build(unlock: ['mangal_3']);
      waiting(run, wrapFor(const {}));
      run.mangal[0].koy();
      cook(run, 30);
      expect(run.mangal[0].yanmis, isTrue);

      run.mangal[2].koy();
      cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);
      expect(run.mangal[2].durum, Pisme.pismis);

      run.beginDrag(slot('mangal_alani', 1));
      final held = run.carried! as PismisEt;
      expect(held.slot, 2);
      expect(held.yanik, isFalse);
    });

    test('with nothing cooked, a burnt skewer comes off instead', () {
      final run = build();
      waiting(run, wrapFor(const {}));
      run.mangal[0].koy();
      cook(run, 30);

      run.beginDrag(slot('mangal_alani', 1));
      final held = run.carried! as PismisEt;
      expect(held.slot, 0);
      expect(held.yanik, isTrue);
    });

    test('an empty grill hands over nothing', () {
      final run = build();
      expect(run.beginDrag(slot('mangal_alani', 0)), isFalse);
    });
  });

  group('the gold', () {
    test('a served customer leaves it on the ledge, not in the till', () {
      final run = build();
      final customer = waiting(run, wrapFor(const {}));
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));
      drag(run, at('durum_hazirlama'), at('musteri_slot_1'));

      expect(run.musteriler[0], isNull, reason: 'they left happy');
      expect(run.progress.para, 0, reason: 'nothing is banked yet');
      expect(run.altin[0]!.miktar, customer.odenen);
      expect(run.altin[0]!.miktar, greaterThan(0));
    });

    test('it lands where the customer stood', () {
      final run = build();
      waiting(run, wrapFor(const {}), slot: 1)
        ..odenen = 25
        ..sabirKalan = 0.05;
      run.tick(0.1);

      expect(run.altin[0], isNull);
      expect(run.altin[1]!.miktar, 25);
    });

    test('a touch anywhere on the ledge takes the nearest pile', () {
      final run = build()
        ..altin[2] = Altin(40)
        ..tap(slot('altin_alani', 0));

      expect(run.progress.para, 40);
      expect(run.altin[2], isNull);
    });

    test('two customers at the same place stack up', () {
      final run = build();
      waiting(run, wrapFor(const {}))
        ..odenen = 10
        ..sabirKalan = 0.05;
      run.tick(0.1);
      waiting(run, wrapFor(const {}))
        ..odenen = 15
        ..sabirKalan = 0.05;
      run.tick(0.1);

      expect(run.altin[0]!.miktar, 25);
    });

    test('left alone it is swept up, most of it', () {
      final run = build()
        ..altin[0] = Altin(100)
        ..tick(Balance.sweptAfter - 0.2);
      expect(run.altin[0], isNotNull, reason: 'still there to be had');
      expect(run.progress.para, 0);

      run.tick(0.3);
      expect(run.altin[0], isNull);
      expect(run.progress.para, 70, reason: 'the tip is what touching buys');
      expect(events, contains(DayEvent.altinSupuruldu));
    });

    test('a second payment restarts the clock on the pile', () {
      final run = build()
        ..altin[0] = Altin(10)
        ..tick(Balance.sweptAfter - 1);
      waiting(run, wrapFor(const {}))
        ..odenen = 15
        ..sabirKalan = 0.05;
      run
        ..tick(0.1)
        ..tick(1.5);

      expect(run.altin[0]!.miktar, 25, reason: 'not half-swept');
    });

    test('an empty ledge does nothing', () {
      final run = build()..tap(slot('altin_alani', 2));
      expect(run.progress.para, 0);
      expect(events, contains(DayEvent.gecersiz));
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
      expect(run.altin[0], isNull, reason: 'a refusal pays nothing');
      // A fifth of what was left, not of the maximum (design doc 8.4).
      expect(
        customer.sabirKalan,
        closeTo(customer.sabirToplam * Balance.refusalKeeps, 0.001),
      );
      // And the wrap is on its shelf, not lost.
      expect(run.durumIstasyonu, isNull);
      expect(run.bekleme.first, isNotNull);
    });

    test('a refused wrap blocks the prep area when the shelf is full', () {
      final run = build();
      waiting(run, wrapFor({'sogan'}));
      buildWrap(run, malzemeler: {Malzeme.domates});
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));

      // One shelf slot is open on day one, and something is already on it.
      run.bekleme[0] = DurumUrun(Durum());
      drag(run, at('durum_hazirlama'), at('musteri_slot_1'));
      expect(run.durumIstasyonu, isNotNull, reason: 'stuck in the prep area');
    });

    test('pays for each item as it is handed over', () {
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
        customer.odenen,
        Balance.income(Balance.tatliBase[Tatli.baklava]!, 1),
      );
      expect(run.musteriler[0], isNotNull, reason: 'the wrap is still owed');

      customer.sabirKalan = 0.05;
      run.tick(0.1);
      expect(run.musteriler[0], isNull);
      // They pay for what they did get, on the way out.
      expect(run.altin[0]!.miktar, customer.odenen);
    });

    test('a customer nobody serves holds the seat until they give up', () {
      // What losing a customer costs: with two seats open, one is tied up for
      // the whole patience bar by somebody who pays nothing.
      final run = build()
        ..musteriler[0] = Customer(order: wrapFor(const {}), day: 1)
        ..musteriler[1] = Customer(order: wrapFor(const {}), day: 1);
      final held = run.musteriler[1];

      for (var i = 0; i < 10; i++) {
        run.tick(0.5);
      }
      expect(run.musteriler[1], same(held), reason: 'both seats are taken');

      run.musteriler[1]!.sabirKalan = 0.05;
      run.tick(0.1);
      expect(run.musteriler[1], isNull);

      for (var i = 0; i < 10; i++) {
        run.tick(0.5);
      }
      expect(run.musteriler[1], isNotNull, reason: 'the seat filled again');
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

    test('takes components while the meat is still on the grill', () {
      final run = build(unlock: ['porsiyon_hatti', 'bilesen_ezme'])
        ..tap(at('tabak_kaynak'));

      // Bread is still first: a bare plate takes nothing.
      drag(run, at('malzeme_ezme'), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.bilesenler, isEmpty);

      drag(run, at('lavas_kaynak'), at('tabak_hazirlama'));
      expect(drag(run, at('malzeme_ezme'), at('tabak_hazirlama')), isTrue);
      expect(run.tabakIstasyonu!.bilesenler, {Bilesen.ezme});
      expect(run.tabakIstasyonu!.hazir, isFalse, reason: 'still no meat');
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
      expect(run.regionAt(at('tabak_kaynak'))?.name, isNot('tabak_kaynak'));
      expect(events, isEmpty);
    });
  });

  group('a touch places what has one place to go', () {
    test('meat goes on the grill', () {
      final run = build()..tap(at('malzeme_kiyma'));
      expect(run.mangal[0].bos, isFalse);
    });

    test('bread starts the wrap, then the plate', () {
      final run = build(unlock: ['porsiyon_hatti'])..tap(at('lavas_kaynak'));
      expect(run.durumIstasyonu, isNotNull);

      run
        ..tap(at('tabak_kaynak'))
        ..tap(at('lavas_kaynak'));
      expect(run.tabakIstasyonu!.lavasli, isTrue, reason: 'the wrap is taken');
    });

    test('cooked meat finds the wrap waiting for it', () {
      final run = build()
        ..tap(at('lavas_kaynak'))
        ..tap(at('malzeme_kiyma'));
      cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);

      run.tap(slot('mangal_alani', 0));
      expect(run.durumIstasyonu!.etli, isTrue);
      expect(run.mangal[0].bos, isTrue, reason: 'it came off the grill');
    });

    test('an ingredient lands on the wrap it belongs to', () {
      final run = build()
        ..tap(at('lavas_kaynak'))
        ..tap(at('malzeme_kiyma'));
      cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);
      run
        ..tap(slot('mangal_alani', 0))
        ..tap(at('malzeme_domates'));
      expect(run.durumIstasyonu!.malzemeler, {Malzeme.domates});
    });

    test('a plate component never lands on a wrap', () {
      final run = build(unlock: ['porsiyon_hatti', 'bilesen_ezme'])
        ..tap(at('lavas_kaynak'))
        ..tap(at('malzeme_ezme'));
      expect(run.durumIstasyonu!.malzemeler, isEmpty);
      expect(run.tabakIstasyonu, isNull);
    });

    test('a jug fills the first empty glass', () {
      final run = build(unlock: ['icecek_hatti', 'icecek_ayran'])
        ..tap(at('bardak_kaynak'))
        ..tap(at('surahi_ayran'));
      expect(run.bardakBekletme[0]!.doluyor, isTrue);
    });

    test('a dessert still needs saying who it is for', () {
      final run = build(unlock: ['tatli_baklava'])..tap(at('tatli_baklava'));
      expect(run.carried, isNull);
      expect(events, isNot(contains(DayEvent.gecersiz)));
    });
  });

  group('touch feedback', () {
    test('touching a live source lights it up rather than refusing', () {
      final run = build()..tap(at('malzeme_domates'));
      expect(run.flashAt('malzeme_domates'), greaterThan(0));
      expect(run.parlama['malzeme_domates']!.ok, isTrue);
      expect(events, isNot(contains(DayEvent.gecersiz)));
    });

    test('a locked area is not on the counter at all', () {
      final run = build()..tap(at('malzeme_biber'));
      expect(run.parlama, isEmpty);
      expect(events, isEmpty);
      expect(run.regionAt(at('malzeme_biber'))?.name, isNot('malzeme_biber'));
    });

    test('a full grill says so where a tap would be silent', () {
      final run = build();
      for (var i = 0; i < 3; i++) {
        run.tap(at('malzeme_kiyma'));
      }
      expect(run.mangal.where((slot) => !slot.bos), hasLength(2));
      expect(events, contains(DayEvent.mangalDolu));
      expect(run.parlama['mangal_alani']!.ok, isFalse);
    });

    test('a cancelled pointer puts back what it lifted, silently', () {
      // The notification shade coming down mid-drag is not a drop.
      final run = build();
      expect(run.beginDrag(at('malzeme_domates')), isTrue);
      run.cancelDrag();

      expect(run.carried, isNull);
      expect(run.durumIstasyonu, isNull, reason: 'nothing was placed');
      expect(events, isEmpty, reason: 'and nothing was reported');
    });

    test('a touch that picked something up puts it back', () {
      final run = build();
      expect(run.beginDrag(at('malzeme_domates')), isTrue);
      run
        ..cancelDrag()
        ..tap(at('malzeme_domates'));

      expect(run.carried, isNull);
      expect(run.parlama['malzeme_domates']!.ok, isTrue);
      expect(events, isNot(contains(DayEvent.gecersiz)));
    });

    test('a glow fades on its own', () {
      final run = build()..tap(at('malzeme_domates'));
      expect(run.parlama, isNotEmpty);
      run.tick(1);
      expect(run.parlama, isEmpty);
    });
  });

  group('the shelf', () {
    test('a wrap is taken back off it and served', () {
      final run = build();
      final customer = waiting(run, wrapFor(const {}));
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));
      expect(
        drag(run, at('durum_hazirlama'), slot('bekleme_alani', 0)),
        isTrue,
      );
      expect(run.bekleme[0], isNotNull);

      expect(
        drag(run, slot('bekleme_alani', 0), at('musteri_slot_1')),
        isTrue,
      );
      expect(run.bekleme[0], isNull, reason: 'the slot it came from cleared');
      expect(customer.anaUrunVerildi, isTrue);
      expect(run.altin[0]!.miktar, greaterThan(0));
    });

    test('a full slot pushes the next product to the first free one', () {
      // Only reachable once a second shelf slot is open; with one slot the
      // preferred index is always the empty one and the fallback never runs.
      final run = build(unlock: ['bekleme_2'])
        ..bekleme[0] = DurumUrun(Durum()..kagitli = true)
        ..durumIstasyonu = (Durum()
          ..etli = true
          ..sarili = true
          ..kagitli = true);

      final first = run.bekleme[0];
      expect(
        drag(run, at('durum_hazirlama'), slot('bekleme_alani', 0)),
        isTrue,
      );
      expect(run.bekleme[0], same(first), reason: 'the occupant stayed put');
      expect(run.bekleme[1], isNotNull);
    });
  });

  group('the plate, end to end', () {
    test('is built, shelved, taken back and paid for', () {
      final run = build(unlock: ['porsiyon_hatti', 'bilesen_ezme']);
      final customer = Customer(
        order: Order(
          tip: UrunTipi.porsiyon,
          ister: {Bilesen.ezme.id},
          istemez: const {},
        ),
        day: run.day,
      )..varis = 1;
      run.musteriler[0] = customer;

      run.tap(at('tabak_kaynak'));
      drag(run, at('lavas_kaynak'), at('tabak_hazirlama'));
      drag(run, at('malzeme_kiyma'), slot('mangal_alani', 0));
      cook(run, Balance.rawSeconds + Balance.cookingSeconds + 0.2);
      drag(run, slot('mangal_alani', 0), at('tabak_hazirlama'));
      drag(run, at('malzeme_ezme'), at('tabak_hazirlama'));
      expect(run.tabakIstasyonu!.hazir, isTrue);

      expect(
        drag(run, at('tabak_hazirlama'), slot('bekleme_alani', 0)),
        isTrue,
      );
      expect(run.tabakIstasyonu, isNull, reason: 'the station cleared');
      expect(run.bekleme[0], isA<PorsiyonUrun>());

      expect(
        drag(run, slot('bekleme_alani', 0), at('musteri_slot_1')),
        isTrue,
      );
      expect(customer.anaUrunVerildi, isTrue);
      expect(
        customer.odenen,
        Balance.income(Balance.porsiyonBase, run.day, ingredients: 1),
      );
    });

    test('a wrap does not settle a plate order', () {
      final run = build(unlock: ['porsiyon_hatti']);
      final order = Order(
        tip: UrunTipi.porsiyon,
        ister: const {},
        istemez: const {},
      );
      expect(order.anaUrunKabul(DurumUrun(Durum()..etli = true)), isFalse);
      expect(order.anaUrunKabul(PorsiyonUrun(Porsiyon())), isTrue);
      expect(run.progress.unlocks.porsiyonHatti, isTrue);
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
    test('ends when the clock does, not when the queue does', () {
      final run = build()..tick(0.1);
      expect(run.bitti, isFalse, reason: 'there is time left');

      run.tick(Balance.runLength(run.day).inSeconds.toDouble());
      expect(run.bitti, isTrue);
      expect(events, contains(DayEvent.gunBitti));
    });

    test('customers keep coming for as long as the clock runs', () {
      final run = build();
      for (var i = 0; i < 200; i++) {
        run.tick(0.5);
      }
      expect(run.bitti, isFalse);
      expect(run.musteriler.where((c) => c != null), isNotEmpty);
    });

    test('seats arrivals only in the places that are open', () {
      final run = build();
      for (var i = 0; i < 40; i++) {
        run.tick(0.5);
      }
      expect(run.musteriler[0], isNotNull);
      expect(run.musteriler[1], isNotNull);
      expect(run.musteriler[2], isNull);
    });

    test('an arriving customer walks in before they order', () {
      final run = build()..tick(0.1);
      final customer = run.musteriler[0]!;
      expect(customer.yerinde, isFalse);
      expect(
        customer.sabirKalan,
        customer.sabirToplam,
        reason: 'patience does not run while they are still walking',
      );

      // Nothing can be handed to somebody who has not asked yet.
      waiting(run, wrapFor(const {}), slot: 1);
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));
      expect(
        drag(run, at('durum_hazirlama'), at('musteri_slot_1')),
        isTrue,
        reason: 'the drag happens; the drop is what is refused',
      );
      expect(customer.anaUrunVerildi, isFalse);
      expect(run.bekleme.first, isNotNull, reason: 'refused, so it shelved');

      // Long enough for even the slowest walker.
      run.tick(Balance.arrivalWalk / Balance.slowestWalk);
      expect(customer.yerinde, isTrue);
    });

    test('reaching for an unpapered wrap lights the paper', () {
      final run = build();
      buildWrap(run);
      run.flickUp(at('durum_hazirlama'));
      expect(run.kagitCagiriyor, 0);

      expect(run.beginDrag(at('durum_hazirlama')), isFalse);
      expect(run.kagitCagiriyor, Balance.hintFor);

      drag(run, at('kagit_kaynak'), at('durum_hazirlama'));
      run.tick(Balance.hintFor + 0.1);
      expect(run.kagitCagiriyor, lessThanOrEqualTo(0));
    });

    test('a customer who leaves walks off and frees the seat at once', () {
      final run = build();
      final customer = waiting(run, wrapFor(const {}))..sabirKalan = 0.05;
      run.tick(0.1);

      expect(run.musteriler[0], isNull, reason: 'the seat is free now');
      expect(run.ayrilanlar, hasLength(1));
      expect(run.ayrilanlar.first.hal, MusteriHali.gidiyorKizgin);
      expect(run.ayrilanlar.first.slot, 0);
      expect(customer.hicAlmadi, isTrue);

      run.tick(Balance.arrivalWalk / Balance.slowestWalk);
      expect(run.ayrilanlar, isEmpty, reason: 'off the screen, off the list');
    });

    test('how the visit went is what they leave as', () {
      final run = build();
      waiting(run, wrapFor(const {}))
        ..odenen = 12
        ..sabirKalan = 0.05;
      run.tick(0.1);
      expect(run.ayrilanlar.single.hal, MusteriHali.gidiyorStabil);

      waiting(run, wrapFor(const {}), slot: 1)
        ..anaUrunVerildi = true
        ..sabirKalan = 0.05;
      run.tick(0.1);
      expect(
        run.ayrilanlar.map((a) => a.hal),
        contains(MusteriHali.gidiyorMutlu),
      );
    });

    test('patience shows on the body long before it runs out', () {
      final run = build();
      final customer = waiting(run, wrapFor(const {}));
      expect(customer.hal, MusteriHali.bekliyorCokSakin);

      customer.sabirKalan = customer.sabirToplam * 0.5;
      expect(customer.hal, MusteriHali.bekliyorStabil);

      customer.sabirKalan = customer.sabirToplam * 0.1;
      expect(customer.hal, MusteriHali.bekliyorKizgin);

      customer.varis = 0;
      expect(customer.hal, MusteriHali.yuruyor, reason: 'not there yet');
    });

    test('an empty wrap station starts asking for bread', () {
      final run = build()..tick(Balance.idleWrap - 0.2);
      expect(run.lavasCagiriyor, isFalse);

      run.tick(0.3);
      expect(run.lavasCagiriyor, isTrue);

      run
        ..tap(at('lavas_kaynak'))
        ..tick(0.1);
      expect(run.lavasCagiriyor, isFalse);
    });

    test('a burnt skewer left on the grill starts asking for the bin', () {
      final run = build();
      run.mangal[0]
        ..koy()
        ..tick(60, run.day);
      expect(run.mangal[0].yanmis, isTrue);

      run.tick(Balance.idleBurnt - 0.2);
      expect(run.copCagiriyor, isFalse);
      run.tick(0.3);
      expect(run.copCagiriyor, isTrue);

      expect(drag(run, slot('mangal_alani', 0), at('cop_alani')), isTrue);
      run.tick(0.1);
      expect(run.copCagiriyor, isFalse);
    });

    test('an empty grill starts asking for meat', () {
      final run = build()..tick(Balance.idleGrill - 0.2);
      expect(run.mangalCagiriyor, isFalse);

      run.tick(0.3);
      expect(run.mangalCagiriyor, isTrue);

      run
        ..tap(at('malzeme_kiyma'))
        ..tick(0.1);
      expect(run.mangalCagiriyor, isFalse, reason: 'a skewer is enough');
    });

    test('does nothing once it is over', () {
      final run = build()..tick(Balance.runLength(1).inSeconds.toDouble() + 1);
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
