@Tags(['golden'])
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/order.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/render/counter.dart';
import 'package:kiyma/game/unlocks.dart';

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

  setUpAll(() async {
    scene = await SceneData.load();
    assets = await GameAssets.load();
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
          ..musteriler[0] = Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: {Malzeme.domates.id, Malzeme.biber.id},
              istemez: {Malzeme.sogan.id},
              tatli: Tatli.baklava,
              icecek: Icecek.ayran,
            ),
            day: 1,
          )
          ..musteriler[2] = Customer(
            order: Order(
              tip: UrunTipi.porsiyon,
              ister: {Bilesen.ezme.id},
              istemez: const {},
            ),
            day: 1,
          );

    // One skewer in each cooking state.
    for (final slot in run.mangal) {
      slot.koy();
    }
    run.mangal[1].tick(3, 1);
    run.mangal[2].tick(6.5, 1);
    run.mangal[3].tick(30, 1);

    run
      ..durumIstasyonu = (Durum()
        ..etli = true
        ..malzemeler.addAll(Malzeme.values))
      ..tabakIstasyonu = (Porsiyon()
        ..lavasli = true
        ..etli = true
        ..bilesenler.addAll(Bilesen.values))
      ..bekleme[0] = DurumUrun(Durum()..kagitli = true)
      ..bekleme[1] = DurumUrun(Durum()..kagitli = true)
      ..bekleme[2] = PorsiyonUrun(Porsiyon())
      ..bardakBekletme[0] = (Bardak()..doldur(Icecek.ayran))
      ..bardakBekletme[1] = (Bardak()..icerik = Icecek.kola)
      ..bardakBekletme[2] = Bardak();

    late Image frame;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      CounterComponent(scene: scene, assets: assets, run: run).render(canvas);
      frame = await recorder.endRecording().toImage(
        scene.size.width.toInt(),
        scene.size.height.toInt(),
      );
    });

    await expectLater(frame, matchesGoldenFile('goldens/counter.png'));
  });
}
