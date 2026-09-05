@Tags(['golden'])
library;

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/kiyma_game.dart';
import 'package:kiyma/presentation/render/halo.dart';

import '../support/scene_from_disk.dart';

/// The counter on screens that are not 16:9.
///
/// The scene was measured in one 1024x576 space and no phone is that shape,
/// so there is always a margin. It used to be black, which the owner called
/// the single most amateur thing about the game. These two shapes — taller
/// and wider than the design box — are what stops it coming back.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;
  late Halos halos;
  ui.Image? backdrop;

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
    scene = sceneFromDisk();
    assets = await GameAssets.load();
    halos = await Halos.bake(scene, assets);
    backdrop = await assets.bakeBackdrop();
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> show(
    WidgetTester tester,
    Size surface,
    EdgeInsets insets,
  ) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final run = DayRun(
      scene: scene,
      progress: Progress(),
      onEvent: (_) {},
      onChanged: () {},
    );
    run.mangal[0].koy();

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: surface, viewPadding: insets),
        child: GameWidget(
          game: KiymaGame(
            scene: scene,
            art: assets,
            halos: halos,
            backdrop: backdrop,
            run: run,
            onPause: () {},
            insets: insets,
          ),
        ),
      ),
    );
    // The loop never stops scheduling, so settling never returns.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
  }

  testWidgets('a tall phone in landscape, with a cutout on the left', (
    tester,
  ) async {
    await show(
      tester,
      const Size(960, 420),
      const EdgeInsets.only(left: 42, bottom: 12),
    );
    await expectLater(
      find.byType(GameWidget<KiymaGame>),
      matchesGoldenFile('goldens/frame_wide.png'),
    );
  });

  testWidgets('a squarer screen, where the margin is above and below', (
    tester,
  ) async {
    await show(tester, const Size(700, 560), EdgeInsets.zero);
    await expectLater(
      find.byType(GameWidget<KiymaGame>),
      matchesGoldenFile('goldens/frame_tall.png'),
    );
  });
}
