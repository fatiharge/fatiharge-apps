import 'dart:ui';

import 'package:flame/components.dart';
import 'package:kiyma/presentation/palette.dart';

/// What fills the screen around the counter.
///
/// The kitchen was measured in one 1024x576 space and a phone is not that
/// shape, so there is always a margin. It used to be black, which is the
/// single loudest way a game can say nobody finished it. Now the room bleeds
/// into it — the same painting, blurred and knocked well down — and the
/// design box sits inside a lit rule, so the margin reads as the dark of a
/// room rather than as the edge of the software.
class Backdrop extends PositionComponent {
  Backdrop({
    required this.blurred,
    required this.stage,
    required this.visible,
  }) : super(priority: -1);

  /// The scene painting, blurred once at startup.
  final Image? blurred;

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

    // Darker at the edges than at the stage, so the eye is pulled inwards,
    // then the stage lit: a shadow thrown outwards and a rule around the box.
    canvas
      ..drawRect(
        view,
        Paint()
          ..shader = Gradient.radial(
            stage.center,
            view.longestSide * 0.62,
            const [Color(0x00000000), Color(0x99100C0B)],
            const [0.45, 1],
          ),
      )
      ..drawRect(
        stage,
        Paint()
          ..color = const Color(0x8C000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 16),
      )
      ..drawRect(
        stage.deflate(1.5),
        Paint()
          ..color = const Color(0xFF241D18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
  }

  double _cover(Image art, Rect view) {
    final byWidth = view.width / art.width;
    final byHeight = view.height / art.height;
    return byWidth > byHeight ? byWidth : byHeight;
  }
}
