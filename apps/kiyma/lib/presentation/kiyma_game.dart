import 'dart:ui' show VoidCallback;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/counter.dart';
import 'package:kiyma/presentation/render/halo.dart';

/// The engine's share of the work: a clock, a gesture stream, and a viewport
/// that keeps the painted kitchen the same shape on every phone.
///
/// One game object per day. Restarting a day builds a new one, which costs
/// nothing — the images live in [GameAssets] and are never reloaded.
class KiymaGame extends FlameGame {
  KiymaGame({
    required this.scene,
    required this.art,
    required this.halos,
    required this.run,
    required this.onPause,
  });

  final SceneData scene;

  /// Not named `assets`: [FlameGame] already has a field by that name.
  final GameAssets art;

  /// The hint glows, blurred once at startup rather than every frame.
  final Halos halos;

  final DayRun run;

  /// The HUD is drawn in the scene, so its buttons are hit-tested there too.
  final VoidCallback onPause;

  @override
  Future<void> onLoad() async {
    // Everything in the art was measured in one 1024x576 space, so the fit is
    // a single letterbox rather than a layout pass. The viewfinder is moved
    // to the top-left because scene coordinates start there, not at a centre.
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: scene.size.width,
      height: scene.size.height,
    )..viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    world.add(
      CounterComponent(
        scene: scene,
        assets: art,
        halos: halos,
        run: run,
        onPause: onPause,
      ),
    );
  }
}
