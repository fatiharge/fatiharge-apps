@Tags(['golden'])
library;

import 'dart:ui';

import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/shop_scene.dart';

import '../support/scene_from_disk.dart';

/// The upgrade screen, twice: a counter on its first day and a counter with
/// everything bought.
///
/// It had no sheet at all, and that is how it shipped for months drawing the
/// painted grill the kitchen stopped using — a player walked out of a room
/// with a steel trough and four lit slots into a shop showing a different
/// grill with one raw skewer laid across it, on the screen asking them to pay
/// for a fourth slot. The two screens have to be the same room.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;

  setUpAll(() async {
    scene = sceneFromDisk();
    assets = await GameAssets.load();
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
  });

  testWidgets('the shop, shut and open', (tester) async {
    final yeni = Unlocks();
    final acik = Unlocks();
    for (final unlock in Unlocks.catalogue) {
      acik.open(unlock.id);
    }

    late Image sayfa;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      for (var i = 0; i < 2; i++) {
        final unlocks = i == 0 ? yeni : acik;
        canvas
          ..save()
          ..translate(0, i * scene.size.height);
        ShopScenePainter(
          scene: scene,
          assets: assets,
          unlocks: unlocks,
          // The two rungs that stand on the grill, so the tags are on the
          // thing this sheet is about.
          etiketler: i == 0 ? const {'mangal_alani': 240} : const {},
          secili: i == 0 ? 'mangal_alani' : null,
        ).paint(canvas, scene.size);
        canvas.restore();
      }
      sayfa = await recorder.endRecording().toImage(
        scene.size.width.toInt(),
        scene.size.height.toInt() * 2,
      );
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/shop.png'));
  });
}
