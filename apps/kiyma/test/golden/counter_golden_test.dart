@Tags(['golden'])
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/counter.dart';
import 'package:kiyma/presentation/render/halo.dart';

import '../support/scene_from_disk.dart';

import '../support/stations.dart';

/// One frame of a fully open counter with something in every state.
///
/// Placement here is arithmetic on measured quads — a wrong sign puts food
/// beside the surface it should rest on, and no assertion about the rules
/// notices. Excluded from CI along with the other goldens: the baseline is
/// rendered by the host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;
  late Halos halos;

  setUpAll(() async {
    scene = sceneFromDisk();
    assets = await GameAssets.load();
    halos = await Halos.bake(scene, assets);
    // Without these the numbers and the grill badges come out as boxes: a
    // golden that cannot show its glyphs is not much of a check on them.
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('the counter, with everything open and in use', (tester) async {
    final progress = Progress();
    for (final unlock in Unlocks.catalogue) {
      progress.unlocks.open(unlock.id);
    }

    final run =
        DayRun(
            scene: scene,
            progress: progress,
            onEvent: (_) {},
            onChanged: () {},
            random: math.Random(11),
          )
          ..musteriler[0] = (Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: {Malzeme.domates.id, Malzeme.biber.id},
              istemez: {Malzeme.sogan.id},
              tatli: Tatli.baklava,
              icecek: Icecek.ayran,
            ),
            day: 1,
          )..varis = 1)
          ..musteriler[1] = (Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: {Malzeme.tursu.id},
              istemez: const {},
              icecek: Icecek.kola,
            ),
            day: 1,
          )..varis = 1)
          ..musteriler[2] = (Customer(
            order: Order(
              tip: UrunTipi.porsiyon,
              ister: {Bilesen.ezme.id},
              istemez: const {},
            ),
            day: 1,
          )..varis = 1);

    // One skewer in each cooking state.
    for (final slot in run.mangal) {
      slot.koy();
    }
    run.mangal[1].tick(3, 1);
    run.mangal[2].tick(6.5, 1);
    run.mangal[3].tick(30, 1);

    run
      ..durumIstasyonu = fullWrap()
      ..tabakIstasyonu = fullPlate()
      // Two wraps that look identical and are not: the chip under each is
      // the only thing that says which is which.
      ..bekleme[0] = DurumUrun(fullWrap()..kagitli = true)
      ..bekleme[1] = DurumUrun(
        Durum()
          ..kagitli = true
          ..malzemeEkle(Malzeme.tursu)
          ..malzemeEkle(Malzeme.tursu)
          ..malzemeEkle(Malzeme.tursu),
      )
      ..bekleme[2] = PorsiyonUrun(fullPlate())
      ..bardakBekletme[0] = (Bardak()..doldur(Icecek.ayran))
      ..bardakBekletme[1] = (Bardak()..icerik = Icecek.kola)
      ..bardakBekletme[2] = Bardak()
      ..altin[0] = Altin(24)
      // The second pile is in its last seconds, so it flashes.
      ..altin[2] = (Altin(8, tip: 1)..kalan = 1)
      // The burnt skewer has been sitting long enough for the bin to ask.
      ..bekleyenYanik = Balance.idleBurnt;

    // A pinned meter, so the plate is drawn alight.
    for (var i = 0; i < 40; i++) {
      run.tempo.servisEdildi(tamami: true, sabirOrani: 1);
    }

    // Something in the air: the counter emits and the pool ages on update,
    // so a still frame shows none of it unless it is asked for.
    final component = CounterComponent(
      scene: scene,
      assets: assets,
      halos: halos,
      run: run,
      onPause: () {},
    );
    for (var i = 0; i < 40; i++) {
      component.update(1 / 60);
    }

    // A sheet in the hand, drawn where the finger is: the paper is the one
    // carryable whose source art is not what leaves it.
    run
      ..beginDrag(scene['kagit_kaynak'].quad.center)
      ..carriedAt = const Offset(470, 330);

    late Image frame;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      component.render(canvas);
      frame = await recorder.endRecording().toImage(
        scene.size.width.toInt(),
        scene.size.height.toInt(),
      );
    });

    await expectLater(frame, matchesGoldenFile('goldens/counter.png'));
  });

  // The other half of the same check: what is *not* on the counter on day one.
  // Locked areas are absent rather than dimmed, and no rule test can see a
  // tray that got drawn anyway.
  testWidgets('the counter on day one, with nothing bought yet', (
    tester,
  ) async {
    final run =
        DayRun(
            scene: scene,
            progress: Progress(),
            onEvent: (_) {},
            onChanged: () {},
            random: math.Random(11),
          )
          ..musteriler[0] = (Customer(order: wrapOrder, day: 1)..varis = 1)
          // An idle counter: the two sources that unblock it are asking.
          ..bosMangal = Balance.idleGrill
          ..bosDurum = Balance.idleWrap;

    late Image frame;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      CounterComponent(
        scene: scene,
        assets: assets,
        halos: halos,
        run: run,
        onPause: () {},
      ).render(canvas);
      frame = await recorder.endRecording().toImage(
        scene.size.width.toInt(),
        scene.size.height.toInt(),
      );
    });

    await expectLater(frame, matchesGoldenFile('goldens/counter_day_one.png'));
  });
}

final wrapOrder = Order(
  tip: UrunTipi.durum,
  ister: {Malzeme.domates.id},
  istemez: {Malzeme.sogan.id},
);
