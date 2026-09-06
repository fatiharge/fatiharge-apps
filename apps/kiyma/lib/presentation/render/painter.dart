import 'dart:math' as math;
import 'dart:ui';

// Prefixed: `dart:ui` and `painting` both define TextStyle and this file
// needs the painting one.
import 'package:flutter/material.dart' as m;
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/domain/scene.dart';

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

/// A baked halo, laid where its asset sits.
///
/// `Halos` renders these once at startup: the shape never changes, and the
/// mask blur that makes one is far too expensive to repeat every frame for
/// every lit hint. [strength] is the pulse.
void drawHalo(
  Canvas canvas,
  Image halo,
  Rect bounds,
  double pad,
  double strength,
) {
  canvas.drawImageRect(
    halo,
    _whole(halo),
    Rect.fromLTWH(
      bounds.left - pad,
      bounds.top - pad,
      bounds.width + pad * 2,
      bounds.height + pad * 2,
    ),
    Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: strength.clamp(0, 1))
      ..filterQuality = FilterQuality.medium,
  );
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
  Color? outline,
  bool right = false,
  bool middle = false,
  double? maxWidth,
}) {
  if (outline != null) {
    // Drawn four times around: a number thrown over a painted kitchen has no
    // guaranteed backdrop, and an outline is what stops it disappearing into
    // a bright tray.
    for (final d in const [
      Offset(-1.6, 0),
      Offset(1.6, 0),
      Offset(0, -1.6),
      Offset(0, 1.6),
    ]) {
      drawText(
        canvas,
        text,
        at + d,
        size: size,
        color: outline.withValues(alpha: color.a),
        center: center,
        weight: weight,
        family: family,
        right: right,
        middle: middle,
        maxWidth: maxWidth,
      );
    }
  }
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
  )..layout(maxWidth: maxWidth ?? double.infinity);
  final dx = center
      ? painter.width / 2
      : right
      ? painter.width
      : 0.0;
  painter.paint(canvas, at - Offset(dx, middle ? painter.height / 2 : 0));
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

/// The highlight along the top of a panel. One translucent band is most of
/// what separates a surface that looks moulded from one that looks printed.
void drawGloss(Canvas canvas, Rect rect) {
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      Rect.fromLTWH(
        rect.left + 5,
        rect.top + 4,
        rect.width - 10,
        rect.height * 0.34,
      ),
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    ),
    Paint()..color = const Color(0x44FFFFFF),
  );
}

/// A key on the panel: a coloured chunky button with the outline and the hard
/// offset shadow every other button in the game has.
void drawKey(Canvas canvas, Rect rect, Color colour) {
  final shape = RRect.fromRectAndRadius(rect, const Radius.circular(13));
  canvas
    ..drawRRect(
      shape.shift(const Offset(0, 3)),
      Paint()..color = const Color(0xFF2E2A26),
    )
    ..drawRRect(shape, Paint()..color = colour)
    ..drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          rect.left + 4,
          rect.top + 3,
          rect.width - 8,
          rect.height * 0.32,
        ),
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()..color = const Color(0x3DFFFFFF),
    )
    ..drawRRect(
      shape.deflate(1),
      Paint()
        ..color = const Color(0xFF2E2A26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
}

/// The paper a kebab shop actually writes an order on.
///
/// The card used to be a blue-black rounded slab — phone interface, not
/// kitchen — sitting in the middle of the drag path. Cream paper with a torn
/// bottom edge and a hard shadow reads as a thing on the counter, and the
/// tilt is what stops three of them looking like one sprite repeated.
void drawTicket(
  Canvas canvas,
  Rect rect, {
  Color fill = const Color(0xFFF7EEDF),
}) {
  final path = Path()
    ..moveTo(rect.left, rect.top + 6)
    ..quadraticBezierTo(rect.left, rect.top, rect.left + 6, rect.top)
    ..lineTo(rect.right - 6, rect.top)
    ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 6)
    ..lineTo(rect.right, rect.bottom - 5);
  // Torn along the bottom, the way a docket comes off the pad.
  const teeth = 9;
  for (var i = teeth; i >= 0; i--) {
    final x = rect.left + rect.width * i / teeth;
    path.lineTo(x, rect.bottom - (i.isEven ? 0 : 6));
  }
  path.close();

  canvas
    ..drawPath(
      path.shift(const Offset(0, 4)),
      Paint()..color = const Color(0xFF2E2A26),
    )
    ..drawPath(path, Paint()..color = fill)
    ..drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2E2A26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
}

/// A socket cut into a panel: a dark inset with a lighter bevel. The plate
/// holds three of them and everything the HUD says is drawn inside one.
void drawSocket(Canvas canvas, Rect rect) {
  final shape = RRect.fromRectAndRadius(rect, const Radius.circular(8));
  canvas
    ..drawRRect(shape, Paint()..color = const Color(0xFF17140F))
    ..drawRRect(
      shape.deflate(0.75),
      Paint()
        ..color = const Color(0x33F5E9D7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
}

/// One Material glyph, centred. Used where a word would need translating and
/// a picture does not.
void drawGlyph(
  Canvas canvas,
  m.IconData icon,
  Offset center,
  double size,
  Color color,
) {
  final painter = m.TextPainter(
    text: m.TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: m.TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
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

/// A sheet torn off the roll.
///
/// Dragging the roll used to carry the roll: a fist-sized cylinder floating
/// across the counter, which is not what a hand takes off a paper roll and
/// read as picking up the dispenser. What moves is one sheet, so one sheet
/// is what is drawn — the tear along the top edge is the whole point of it.
void drawTornSheet(Canvas canvas, Offset centre, double width, double turn) {
  final height = width * 0.74;
  canvas
    ..save()
    ..translate(centre.dx, centre.dy)
    ..rotate(turn);

  // An irregular tear, from a fixed table rather than a random one: a
  // regular sawtooth reads as a stamped edge, and paper does not tear evenly.
  // Fixed so the sheet does not crawl from frame to frame — and so a golden
  // that draws one is the same picture twice.
  const tear = [0.0, 0.11, 0.02, 0.14, 0.05, 0.16, 0.03, 0.09, 0.0];
  const drift = [0.0, 0.02, -0.03, 0.01, 0.03, -0.02, 0.02, -0.01, 0.0];
  final path = Path()..moveTo(-width / 2, -height / 2);
  for (var i = 1; i < tear.length; i++) {
    path.lineTo(
      width * (i / (tear.length - 1) - 0.5 + drift[i]),
      -height / 2 + height * tear[i],
    );
  }
  path
    ..lineTo(width / 2, height * 0.44)
    // The bottom edge hangs: a sheet held at the top is not a rectangle.
    ..quadraticBezierTo(0, height * 0.56, -width / 2, height * 0.42)
    ..close();

  canvas
    ..drawPath(
      path.shift(const Offset(2, 4)),
      Paint()..color = const Color(0x33000000),
    )
    ..drawPath(path, Paint()..color = const Color(0xFFFBF6EC))
    ..drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2E2A26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    )
    // A fold, so the sheet has a front and a back rather than a shape.
    ..drawLine(
      Offset(width * 0.14, -height * 0.3),
      Offset(width * 0.14, height * 0.46),
      Paint()
        ..color = const Color(0x1A2E2A26)
        ..strokeWidth = 2,
    )
    ..restore();
}
