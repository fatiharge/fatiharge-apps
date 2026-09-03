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
void drawInQuad(Canvas canvas, Image image, Quad quad, AssetFit fit) {
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
    ..drawImageRect(image, _whole(image), dest, _paint)
    ..restore();
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

/// Draws [image] centred on [center] at [width], keeping its aspect. Used for
/// the thing under the finger and for the icons on an order card.
void drawCentered(Canvas canvas, Image image, Offset center, double width) {
  final height = width * image.height / image.width;
  canvas.drawImageRect(
    image,
    _whole(image),
    Rect.fromCenter(center: center, width: width, height: height),
    _paint,
  );
}

void drawText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 11,
  Color color = const Color(0xFFFFFFFF),
  bool center = false,
  bool bold = false,
}) {
  final painter = m.TextPainter(
    text: m.TextSpan(
      text: text,
      style: m.TextStyle(
        fontSize: size,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        height: 1.1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center ? at - Offset(painter.width / 2, 0) : at);
}

/// A padlock, drawn over anything money has not opened yet.
///
/// Locked areas stay on the counter rather than disappearing: the player
/// should be able to see what the next purchase buys.
void drawLock(Canvas canvas, Quad quad, {double size = 16}) {
  canvas.drawPath(quad.toPath(), Paint()..color = const Color(0x99101014));
  final painter = m.TextPainter(
    text: m.TextSpan(
      text: String.fromCharCode(m.Icons.lock.codePoint),
      style: m.TextStyle(
        fontSize: size,
        fontFamily: m.Icons.lock.fontFamily,
        package: m.Icons.lock.fontPackage,
        color: const Color(0xCCFFFFFF),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    quad.center - Offset(painter.width / 2, painter.height / 2),
  );
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
