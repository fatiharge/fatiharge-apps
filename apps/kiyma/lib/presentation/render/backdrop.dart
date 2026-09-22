import 'dart:ui';

import 'package:flame/components.dart';
import 'package:kiyma/presentation/palette.dart';

/// What fills the screen around the counter.
///
/// The kitchen was measured in one 1024x576 space and a phone is not that
/// shape, so there is always a margin. It was black first, which is the
/// single loudest way a game can say nobody finished it, and then the scene
/// blurred and knocked down, which reads as a screensaver playing behind a
/// game.
///
/// The answer is not to dress the margin but to remove it: [room] is the
/// same painting continued outwards, half a box further in every direction,
/// so a wide phone and a squarer tablet both see more kitchen rather than
/// more treatment. The playable box is untouched — it is still the 1024x576
/// everything was measured in — and nothing outside it is ever hit tested.
///
/// The blur stays as the floor under it: a screen wider than 1.5 boxes would
/// otherwise run out of painting.
class Backdrop extends PositionComponent {
  Backdrop({
    required this.blurred,
    required this.room,
    required this.stage,
    required this.visible,
  }) : super(priority: -1);

  /// The scene painting, blurred once at startup. Only ever seen if a
  /// screen is wider or taller than the painted room.
  final Image? blurred;

  /// The room, painted 1.5 boxes wide and tall around the design box.
  ///
  /// Softened on the way in rather than at runtime. The generator cannot
  /// continue a tile grid exactly, and a hard edge between two versions of
  /// the same wall is worse than no extension at all; a ring a little out of
  /// focus reads as depth instead, and the scene it surrounds is drawn
  /// sharp on top of it.
  final Image? room;

  /// The design box: everything the game was measured in.
  final Rect stage;

  /// What the camera can currently see, in world units.
  final Rect Function() visible;

  static final _knock = Paint()..color = const Color(0xC2140F0E);

  @override
  void render(Canvas canvas) {
    final view = visible().inflate(2);
    if (view.isEmpty) return;

    final art = blurred;
    if (art == null) {
      canvas.drawRect(view, Paint()..color = KiymaPalette.zemin);
    } else {
      // Cover, so the blur never runs out before the margin does.
      final scale = _cover(art, view);
      final w = art.width * scale;
      final h = art.height * scale;
      canvas
        ..drawImageRect(
          art,
          Rect.fromLTWH(0, 0, art.width.toDouble(), art.height.toDouble()),
          Rect.fromCenter(center: view.center, width: w, height: h),
          Paint()..filterQuality = FilterQuality.low,
        )
        ..drawRect(view, _knock);
    }

    final painted = room;
    if (painted != null) {
      canvas.drawImageRect(
        painted,
        Rect.fromLTWH(
          0,
          0,
          painted.width.toDouble(),
          painted.height.toDouble(),
        ),
        // Against the *drawn* scene, not the design box: the painted layer is
        // inflated by 16 so a knock cannot expose a strip the art never
        // covered, and matching the box instead left the room 3% small —
        // which the eye reads as a wall of smaller tiles.
        Rect.fromCenter(
          center: stage.center,
          width: (stage.width + 32) * 1.5,
          height: (stage.height + 32) * 1.5,
        ),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }

    // Still darker at the edges than at the middle, so the eye is pulled to
    // the counter — but no rule and no drop shadow around the box. Those were
    // drawing a frame around the playable area, and the whole point of the
    // painted room is that there is no frame.
    canvas.drawRect(
      view,
      Paint()
        ..shader = Gradient.radial(
          stage.center,
          view.longestSide * 0.7,
          const [Color(0x00000000), Color(0x5C100C0B)],
          const [0.5, 1],
        ),
    );
  }

  double _cover(Image art, Rect view) {
    final byWidth = view.width / art.width;
    final byHeight = view.height / art.height;
    return byWidth > byHeight ? byWidth : byHeight;
  }
}
