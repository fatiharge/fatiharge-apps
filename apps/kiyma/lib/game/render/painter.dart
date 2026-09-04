import 'dart:math' as math;
import 'dart:ui';

// Prefixed: `dart:ui` and `painting` both define TextStyle and this file
// needs the painting one.
import 'package:flutter/material.dart' as m;
import 'package:kiyma/core/quad.dart';
import 'package:kiyma/data/scene.dart';

final _paint = Paint()..filterQuality = FilterQuality.medium;

Rect _whole(Image image) =>
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

/// Draws [image] inside [quad], in the quad's own axes.
///
/// Width runs along the top edge, height along the left edge, and the whole
/// thing is rotated by the top edge's slope. Fitting to the bounding box
/// instead puts food visibly off the surface it is supposed to rest on,
/// because the counter leans.
void drawInQuad(
  Canvas canvas,
  Image image,
  Quad quad,
  AssetFit fit, {
  Paint? paint,
}) {
  final w = quad.width;
  final h = quad.height;
  canvas
    ..save()
    ..translate(quad.topLeft.dx, quad.topLeft.dy)
    ..rotate(quad.angle);

  final dest = switch (fit) {
    AssetFit.doldur => Rect.fromLTWH(0, 0, w, h),
    _ => () {
      final scale = math.min(w / image.width, h / image.height);
      final dw = image.width * scale;
      final dh = image.height * scale;
      // `alt` sits on the floor of the area; `orta` centres.
      final top = fit == AssetFit.alt ? h - dh : (h - dh) / 2;
      return Rect.fromLTWH((w - dw) / 2, top, dw, dh);
    }(),
  };

  canvas
    ..drawImageRect(image, _whole(image), dest, paint ?? _paint)
    ..restore();
}

/// A halo in [color] hugging [image]'s own silhouette, drawn behind it.
///
/// The glow follows the art rather than the region box, because a region is
/// a hit target: a rectangle of light around a tray of parsley reads as an
/// overlay laid on the scene, where a halo reads as the thing itself asking.
/// Laid down three times — once is too faint to find on a busy counter.
void drawGlow(
  Canvas canvas,
  Image image,
  Quad quad,
  AssetFit fit,
  Color color,
  double strength,
) {
  final paint = Paint()
    ..colorFilter = ColorFilter.mode(
      color.withValues(alpha: strength.clamp(0, 1)),
      BlendMode.srcIn,
    )
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
    ..filterQuality = FilterQuality.medium;
  for (var i = 0; i < 3; i++) {
    drawInQuad(canvas, image, quad, fit, paint: paint);
  }
}

/// Draws one layer of a built-up product: sized as a fraction of the region's
/// width, offset from its centre, rotated with it.
void drawCompositionLayer(
  Canvas canvas,
  Image image,
  Quad quad,
  CompositionLayer layer,
) {
  final w = quad.width * layer.widthRatio;
  final h = w * image.height / image.width;
  canvas
    ..save()
    ..translate(quad.center.dx, quad.center.dy)
    ..rotate(quad.angle)
    ..translate(quad.width * layer.offsetX, quad.height * layer.offsetY)
    ..drawImageRect(
      image,
      _whole(image),
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      _paint,
    )
    ..restore();
}

/// How wide [image] comes out when fitted into [quad].
double widthInQuad(Image image, Quad quad) =>
    image.width *
    math.min(quad.width / image.width, quad.height / image.height);

/// Draws [image] centred on [center] at [width], keeping its aspect. Used for
/// the thing under the finger and for the icons on an order card.
void drawCentered(
  Canvas canvas,
  Image image,
  Offset center,
  double width, {
  Paint? paint,
}) {
  final height = width * image.height / image.width;
  canvas.drawImageRect(
    image,
    _whole(image),
    Rect.fromCenter(center: center, width: width, height: height),
    paint ?? _paint,
  );
}

void drawText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 11,
  Color color = const Color(0xFFFFFFFF),
  bool center = false,
  int weight = 500,
  String? family,
}) {
  final painter = m.TextPainter(
    text: m.TextSpan(
      text: text,
      style: m.TextStyle(
        fontSize: size,
        color: color,
        fontFamily: family,
        fontVariations: family == null
            ? null
            : [FontVariation('wght', weight.toDouble())],
        fontWeight: FontWeight.values[(weight ~/ 100) - 1],
        height: 1.1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center ? at - Offset(painter.width / 2, 0) : at);
}

/// A cream panel with the design's dark outline and hard offset shadow — the
/// screens' chunky button, drawn into the scene so the HUD belongs to the
/// game rather than floating over it.
void drawPanel(
  Canvas canvas,
  Rect rect, {
  Color fill = const Color(0xFFF5E9D7),
}) {
  final shape = RRect.fromRectAndRadius(rect, const Radius.circular(18));
  canvas
    ..drawRRect(
      shape.shift(const Offset(0, 6)),
      Paint()..color = const Color(0xFF2E2A26),
    )
    ..drawRRect(shape, Paint()..color = fill)
    ..drawRRect(
      shape.deflate(2),
      Paint()
        ..color = const Color(0xFF2E2A26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
}

/// A segmented ring with an icon in the middle: what a grill slot is doing.
///
/// A straight bar lying along a skewer came out as four coloured specks on a
/// leaning grill — indistinguishable from each other and from the coals. A
/// dial reads as one object in one state, which is what a slot is.
void drawDial(
  Canvas canvas,
  Offset center,
  double radius,
  double value, {
  required Color lit,
  required Color dark,
  required m.IconData icon,
  int segments = 8,
}) {
  final band = radius * 0.36;
  final ring = Rect.fromCircle(center: center, radius: radius - band / 2);

  canvas
    ..drawCircle(center, radius, Paint()..color = dark)
    ..drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0, 1),
      false,
      Paint()
        ..color = lit
        ..style = PaintingStyle.stroke
        ..strokeWidth = band,
    );

  // The gaps are cut out of the ring rather than drawn as segments: one arc
  // and a handful of lines, whatever the value is.
  for (var i = 0; i < segments; i++) {
    final angle = -math.pi / 2 + math.pi * 2 * i / segments;
    final unit = Offset(math.cos(angle), math.sin(angle));
    canvas.drawLine(
      center + unit * (radius - band),
      center + unit * radius,
      Paint()
        ..color = dark
        ..strokeWidth = radius * 0.14,
    );
  }

  canvas
    ..drawCircle(
      center,
      radius - 0.75,
      Paint()
        ..color = lit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    )
    ..drawCircle(center, radius - band - 1, Paint()..color = dark);

  final glyph = m.TextPainter(
    text: m.TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: m.TextStyle(
        fontSize: radius * 1.15,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: lit,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  glyph.paint(canvas, center - Offset(glyph.width / 2, glyph.height / 2));
}

/// A rounded meter. Used for cooking progress and for patience, which are the
/// two clocks the player has to read at a glance.
void drawBar(
  Canvas canvas,
  Rect rect,
  double value, {
  required Color color,
  Color background = const Color(0x66000000),
  double angle = 0,
}) {
  final radius = Radius.circular(rect.height / 2);
  canvas.save();
  if (angle != 0) {
    // Rotated about its own centre, so a meter over a skewer lies along the
    // skewer rather than cutting across it.
    canvas
      ..translate(rect.center.dx, rect.center.dy)
      ..rotate(angle)
      ..translate(-rect.center.dx, -rect.center.dy);
  }
  canvas
    ..drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = background,
    )
    ..drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left,
          rect.top,
          rect.width * value.clamp(0, 1),
          rect.height,
        ),
        radius,
      ),
      Paint()..color = color,
    )
    ..restore();
}
