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
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/counter.dart';
import 'package:kiyma/presentation/render/halo.dart';

import '../support/scene_from_disk.dart';

/// Every badge the counter can raise, at once, over the room it is raised in.
///
/// The point of the sheet is *placement*. A badge reads fine on a grey card
/// and still lands on the ticket the player is reading, half off the left
/// edge, or over the coals it is warning about — and none of that shows up
/// anywhere but here. It goes through the real path, `run.cues` into the
/// component, so the anchors are the ones the rules give and the words are
/// the ones the translation file holds.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;
  late Halos halos;

  // Decoding images inside a widget test deadlocks against its fake clock, so
  // the bundle is opened here, the way the other golden sheets open it.
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

  testWidgets('every notice, where it is raised', (tester) async {
    final progress = Progress();
    for (final unlock in Unlocks.catalogue) {
      progress.unlocks.open(unlock.id);
    }
    final run = DayRun(
      scene: scene,
      progress: progress,
      onEvent: (_) {},
      onChanged: () {},
      random: math.Random(4),
    );
    // Three seated customers, so the badges over them have something to be
    // about and something to cover.
    for (var i = 0; i < 3; i++) {
      run.musteriler[i] = Customer(
        order: Order(
          tip: ProductKind.durum,
          ister: {Ingredient.domates.id},
          istemez: {Ingredient.sogan.id},
        ),
        day: 3,
      )..varis = 1;
    }
    // Past the two forgiven mis-moves: below that the counter says nothing
    // about a slip, which is the whole rule.
    for (var i = 0; i < 3; i++) {
      run.tempo.gecersizHareket();
    }

    final component = CounterComponent(
      ceviri: (key) => _sozluk[key] ?? key,
      scene: scene,
      assets: assets,
      halos: halos,
      run: run,
      onPause: () {},
    );
    for (var i = 0; i < 30; i++) {
      component.update(1 / 60);
    }

    Offset musteri(int slot) =>
        scene['musteri_slot_${slot + 1}'].quad.bounds.center;
    run.cues.addAll([
      Cue(DayEvent.musteriKizgin, musteri(0)),
      Cue(DayEvent.reddedildi, musteri(1)),
      Cue(DayEvent.bahsis, musteri(2), amount: 12, asset: 'altin'),
      Cue(DayEvent.mangalDolu, scene['mangal_alani'].quad.at(.5, 0)),
      Cue(DayEvent.yandi, scene['mangal_alani'].slots[0].center, amount: -18),
      Cue(
        DayEvent.altinSupuruldu,
        scene['altin_alani'].slots[0].center,
        amount: -7,
      ),
      Cue(
        DayEvent.sonSiparis,
        scene['tezgah_ust_kenari'].quad.bounds.topCenter,
      ),
      Cue(
        DayEvent.gunlukHedef,
        scene['tezgah_ust_kenari'].quad.bounds.center,
        amount: 40,
        asset: 'altin',
      ),
      Cue(DayEvent.gecersiz, scene['durum_hazirlama'].quad.bounds.center),
    ]);
    // Long enough to be past the entrance and short of the fade: how a badge
    // looks for the second it is being read.
    for (var i = 0; i < 36; i++) {
      component.update(1 / 60);
    }

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

    await expectLater(frame, matchesGoldenFile('goldens/notices.png'));
  });
}

/// The Turkish side of `olay.*`, so the sheet shows the words at the length
/// they ship at rather than at the length of a key.
const _sozluk = {
  'olay.musteri_kizgin': 'Müşteri gitti',
  'olay.reddedildi': 'Sipariş tutmadı',
  'olay.bahsis': 'Bahşiş bıraktı',
  'olay.mangal_dolu': 'Mangalda yer yok',
  'olay.yandi': 'Kıyma yandı',
  'olay.altin_supuruldu': "Altının %30'u gitti",
  'olay.son_siparis': 'Son sipariş!',
  'olay.gunluk_hedef': 'Günün hedefi tamam',
  'olay.gecersiz': 'Olmaz',
};
