import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/presentation/render/backdrop.dart';
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
    this.backdrop,
    this.insets = EdgeInsets.zero,
  });

  final SceneData scene;

  /// Not named `assets`: [FlameGame] already has a field by that name.
  final GameAssets art;

  /// The hint glows, blurred once at startup rather than every frame.
  final Halos halos;

  final DayRun run;

  /// The HUD is drawn in the scene, so its buttons are hit-tested there too.
  final VoidCallback onPause;

  /// The blurred plate the margin is painted with.
  final Image? backdrop;

  /// What the notch, the camera cutout and the gesture bar are covering. The
  /// counter is kept out of all of it.
  EdgeInsets insets;

  /// Never let the box touch the glass, even where the system says it may:
  /// rounded corners eat the last few pixels on every modern phone.
  /// No breathing room of its own: the only inset is what the platform
  /// actually reserves.
  ///
  /// It was 20 on every side, from when the margin was decoration and the
  /// design box wanted to sit off the screen edge. With the room painted
  /// through it does the opposite — it forces a strip of painted room above
  /// and below the counter on a phone that would otherwise have none, and
  /// two versions of the same kitchen meeting in a straight line is exactly
  /// what a margin must never look like.
  static const _gutter = 0.0;

  @override
  Color backgroundColor() => KiymaPalette.zemin;

  @override
  Future<void> onLoad() async {
    // Not `withFixedResolution`: that clips to a 16:9 window and leaves the
    // rest of the screen as whatever is behind the game, which was black —
    // the loudest way software can say nobody finished it. An unclipped
    // camera at the same zoom shows exactly the same counter and lets the
    // margin be painted.
    camera = CameraComponent(world: world)..viewfinder.anchor = Anchor.center;

    await world.addAll([
      Backdrop(
        blurred: backdrop,
        room: art['oda.jpg'],
        stage: Offset.zero & Size(scene.size.width, scene.size.height),
        visible: () => camera.visibleWorldRect,
      ),
      CounterComponent(
        visible: () => camera.visibleWorldRect,
        scene: scene,
        assets: art,
        halos: halos,
        run: run,
        onPause: onPause,
      ),
    ]);
    _fit(size);
  }

  /// The system's furniture moved — a fold opened, the bar came back.
  void insetsChanged(EdgeInsets value) {
    insets = value;
    if (isLoaded) _fit(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _fit(size);
  }

  /// Fits the design box into what is left after the system's furniture, and
  /// centres it there rather than on the screen — so a notch on one side does
  /// not push the counter under it.
  void _fit(Vector2 view) {
    final left = math.max(insets.left, _gutter);
    final right = math.max(insets.right, _gutter);
    final top = math.max(insets.top, _gutter);
    final bottom = math.max(insets.bottom, _gutter);

    final zoom = math.max(
      0.01,
      math.min(
        (view.x - left - right) / scene.size.width,
        (view.y - top - bottom) / scene.size.height,
      ),
    );
    camera.viewfinder
      ..zoom = zoom
      ..position = Vector2(
        scene.size.width / 2 + (right - left) / 2 / zoom,
        scene.size.height / 2 + (bottom - top) / 2 / zoom,
      );
  }
}
