@Tags(['golden'])
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tutor.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/counter.dart';
import 'package:kiyma/presentation/render/halo.dart';

import '../support/scene_from_disk.dart';

/// The teaching frame, at the four steps that put the target in four
/// different corners.
///
/// Where the bubble lands is the whole of what this checks. A tutorial that
/// covers the thing it is pointing at teaches nothing, and the only way to
/// see that happen is to draw it over the room with a customer in it and
/// something on every station.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;
  late Halos halos;

  setUpAll(() async {
    scene = sceneFromDisk();
    assets = await GameAssets.load();
    halos = await Halos.bake(scene, assets);
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('the usta teaching, at four targets', (tester) async {
    // One step per corner of the room: the grill bottom-left, the trays
    // across the middle, the wrap board, the customer top-centre.
    const adimlar = [0, 3, 5, 7];

    late Image sayfa;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      for (var i = 0; i < adimlar.length; i++) {
        final ogretmen = Tutor(Lesson.ilkGun);
        for (var k = 0; k < adimlar[i]; k++) {
          ogretmen
            ..ilerlet()
            ..ulasildi(Lesson.ilkGun.adimlar[k].bekler ?? Milestone.etPisti);
        }
        final run = DayRun(
          scene: scene,
          progress: Progress(),
          onEvent: (_) {},
          onChanged: () {},
          random: math.Random(7),
          ogretmen: ogretmen,
        );
        run.musteriler[0] = (Customer(
          order: Order(
            tip: ProductKind.durum,
            ister: {Ingredient.domates.id},
            istemez: const {},
          ),
          day: 1,
        )..varis = 1);

        final component = CounterComponent(
          ceviri: (key) => _sozluk[key] ?? key,
          scene: scene,
          assets: assets,
          halos: halos,
          run: run,
          onPause: () {},
        );
        for (var k = 0; k < 40; k++) {
          component.update(1 / 60);
        }
        canvas
          ..save()
          ..translate(
            (i % 2) * scene.size.width,
            (i ~/ 2) * scene.size.height,
          );
        component.render(canvas);
        canvas.restore();
      }
      sayfa = await recorder.endRecording().toImage(
        scene.size.width.toInt() * 2,
        scene.size.height.toInt() * 2,
      );
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/ders.png'));
  });
}

const _sozluk = {
  'ders.ilk_gun.lavas': 'Lavaşı al ve dürüm alanına koy.',
  'ders.ilk_gun.kiyma': 'Kıymayı mangala at.',
  'ders.ilk_gun.bekle': 'Kızarmasını bekle. Sarı tik çıkınca hazır.',
  'ders.ilk_gun.eti_al': 'Eti al, dürümün üstüne koy.',
  'ders.ilk_gun.malzeme': 'Domates ekle. Bir malzeme üç tutam.',
  'ders.ilk_gun.sar': 'Dürümün üstünde yukarı fiske at, sarılsın.',
  'ders.ilk_gun.kagit': 'Kâğıdı al, sarılan dürümün üstüne koy.',
  'ders.ilk_gun.ver': 'Müşteriye ver.',
  'ders.ilk_gun.altin': 'Parayı tezgahtan al. Bırakırsan bir kısmı gider.',
  'ders.ilk_gun.bitti': 'Tezgah senin. Kolay gelsin.',
  'tanitim.atla': 'Atla',
};
