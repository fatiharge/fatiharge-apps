/// Flat, ink-outlined marks drawn at the size they are actually read.
///
/// The order card shows eight ingredients at about twenty pixels across. It
/// used to show the tray art scaled down to that, and eight brown-grey
/// smudges is what came back: those assets were drawn to be read at sixty
/// pixels on a counter, and no amount of filtering puts detail back into
/// something that never had it at that size. These are authored for twenty —
/// one silhouette, one colour, one mark each — so the row can be scanned
/// under time pressure, which is the only thing the row is for.
///
/// Every glyph is drawn in a unit box centred on the origin, so the outline
/// scales with the mark and stays the same weight relative to it.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

const _ink = Color(0xFF2E2A26);

/// Whether [id] has a mark. Anything without one falls back to the art.
bool hasGlyph(String id) => _glyphs.containsKey(id);

/// Draws the mark for [id] centred at [at], [size] across.
void drawGameGlyph(
  Canvas canvas,
  String id,
  Offset at,
  double size, {
  double alpha = 1,
}) {
  final glyph = _glyphs[id];
  if (glyph == null) return;
  final faded = alpha < 1;
  if (faded) {
    canvas.saveLayer(
      Rect.fromCenter(center: at, width: size * 2, height: size * 2),
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
    );
  }
  canvas
    ..save()
    ..translate(at.dx, at.dy)
    ..scale(size);
  glyph(_Pen(canvas));
  canvas.restore();
  if (faded) canvas.restore();
}

/// The one drawing primitive the glyphs share: a filled shape with the ink
/// outline every asset in the game has.
class _Pen {
  _Pen(this.canvas);

  final Canvas canvas;

  static final _line = Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.075
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void path(Path path, Color fill, {bool outline = true}) {
    canvas.drawPath(path, Paint()..color = fill);
    if (outline) canvas.drawPath(path, _line);
  }

  void oval(Rect rect, Color fill, {double turn = 0, bool outline = true}) {
    canvas.save();
    if (turn != 0) {
      canvas
        ..translate(rect.center.dx, rect.center.dy)
        ..rotate(turn)
        ..translate(-rect.center.dx, -rect.center.dy);
    }
    path(Path()..addOval(rect), fill, outline: outline);
    canvas.restore();
  }

  void bar(Rect rect, Color fill, {double turn = 0, double radius = 0.06}) {
    canvas.save();
    if (turn != 0) {
      canvas
        ..translate(rect.center.dx, rect.center.dy)
        ..rotate(turn)
        ..translate(-rect.center.dx, -rect.center.dy);
    }
    path(
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))),
      fill,
    );
    canvas.restore();
  }

  /// A mark with no outline of its own: seeds, grains, a highlight.
  void dot(Offset at, double r, Color fill) =>
      canvas.drawCircle(at, r, Paint()..color = fill);

  void stroke(Path p, Color colour, double width) => canvas.drawPath(
    p,
    Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round,
  );
}

/// A pointed oval — the shape of a pepper, a pickle, a köfte.
Path _spindle(double halfWidth, double halfHeight) => Path()
  ..moveTo(0, -halfHeight)
  ..quadraticBezierTo(halfWidth, -halfHeight * 0.35, halfWidth * 0.82, 0)
  ..quadraticBezierTo(halfWidth * 0.6, halfHeight, 0, halfHeight)
  ..quadraticBezierTo(-halfWidth * 0.6, halfHeight, -halfWidth * 0.82, 0)
  ..quadraticBezierTo(-halfWidth, -halfHeight * 0.35, 0, -halfHeight)
  ..close();

/// Rotated about the origin. A column-major 4x4 built by hand, rather than
/// pulling in vector_math for one matrix.
Path _turned(Path path, double turn) {
  final c = math.cos(turn);
  final s = math.sin(turn);
  return path.transform(
    Float64List.fromList([c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]),
  );
}

final Map<String, void Function(_Pen)> _glyphs = {
  // --- Wrap ingredients ---
  'domates': (p) {
    p
      ..oval(
        Rect.fromCircle(center: const Offset(0, 0.07), radius: 0.36),
        const Color(0xFFD8462F),
      )
      ..dot(const Offset(-0.13, -0.05), 0.07, const Color(0x55FFFFFF))
      ..path(
        Path()
          ..moveTo(0, -0.42)
          ..lineTo(0.2, -0.3)
          ..lineTo(0.08, -0.24)
          ..lineTo(0, -0.34)
          ..lineTo(-0.08, -0.24)
          ..lineTo(-0.2, -0.3)
          ..close(),
        const Color(0xFF4E8A3C),
      );
  },
  'sogan': (p) {
    p
      ..oval(
        Rect.fromCircle(center: Offset.zero, radius: 0.38),
        const Color(0xFFEDDCEF),
      )
      ..stroke(
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.24)),
        const Color(0xFFA678B8),
        0.075,
      )
      ..stroke(
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.11)),
        const Color(0xFFA678B8),
        0.075,
      );
  },
  'biber': (p) {
    p
      ..path(
        _turned(_spindle(0.19, 0.38), -0.34).shift(const Offset(0.02, 0.06)),
        const Color(0xFF5FA23C),
      )
      ..bar(
        Rect.fromCenter(
          center: const Offset(-0.11, -0.31),
          width: 0.09,
          height: 0.17,
        ),
        const Color(0xFF3F6B2A),
        turn: -0.34,
        radius: 0.04,
      );
  },
  // Cut lengthwise, and a paler yellow-green than the pepper. Two saturated
  // green spindles side by side on an order card were one shape twice.
  'tursu': (p) {
    p
      ..path(_turned(_spindle(0.21, 0.36), 0.42), const Color(0xFF7F9331))
      ..path(
        _turned(_spindle(0.13, 0.26), 0.42),
        const Color(0xFFD8DE93),
        outline: false,
      );
    for (final at in const [
      Offset(-0.08, 0.07),
      Offset.zero,
      Offset(0.08, -0.07),
    ]) {
      p.dot(at, 0.035, const Color(0xFF7F9331));
    }
  },

  // --- Plate components ---
  'icli_kofte': (p) {
    p
      ..path(
        _turned(_spindle(0.22, 0.4), 0.38),
        const Color(0xFFA9642F),
      )
      ..dot(const Offset(-0.1, -0.08), 0.05, const Color(0x44FFFFFF));
  },
  'pilav': (p) {
    p.path(
      Path()
        ..moveTo(-0.4, 0.26)
        ..quadraticBezierTo(-0.34, -0.3, 0, -0.3)
        ..quadraticBezierTo(0.34, -0.3, 0.4, 0.26)
        ..close(),
      const Color(0xFFE8CE8C),
    );
    for (final at in const [
      Offset(-0.14, 0.1),
      Offset(0.12, 0.02),
      Offset(-0.02, -0.14),
      Offset(0.2, 0.16),
    ]) {
      p.dot(at, 0.045, const Color(0xFFB99C4E));
    }
  },
  'patates': (p) {
    for (final (i, turn) in [-0.42, -0.02, 0.38].indexed) {
      p.bar(
        Rect.fromCenter(
          center: Offset(-0.18 + i * 0.18, 0.02),
          width: 0.17,
          height: 0.66,
        ),
        const Color(0xFFEBA92E),
        turn: turn,
        radius: 0.08,
      );
    }
  },
  'ezme': (p) {
    p.path(
      Path()
        ..moveTo(-0.42, -0.06)
        ..lineTo(0.42, -0.06)
        ..quadraticBezierTo(0.34, 0.34, 0, 0.34)
        ..quadraticBezierTo(-0.34, 0.34, -0.42, -0.06)
        ..close(),
      const Color(0xFFEFE6D6),
    );
    for (final at in const [
      Offset(-0.16, -0.14),
      Offset(0.06, -0.2),
      Offset(0.22, -0.11),
    ]) {
      p.dot(at, 0.1, const Color(0xFFC4321F));
    }
  },

  // --- What the order is for ---
  'durum': (p) {
    p
      ..bar(
        Rect.fromCenter(center: Offset.zero, width: 0.34, height: 0.84),
        const Color(0xFFEFD9A8),
        turn: -0.42,
        radius: 0.14,
      )
      ..bar(
        Rect.fromCenter(
          center: const Offset(0.09, 0.19),
          width: 0.38,
          height: 0.3,
        ),
        const Color(0xFFFBF6EC),
        turn: -0.42,
        radius: 0.05,
      )
      ..oval(
        Rect.fromCenter(
          center: const Offset(-0.17, -0.35),
          width: 0.3,
          height: 0.14,
        ),
        const Color(0xFF8C4326),
        turn: -0.42,
      );
  },
  'porsiyon': (p) {
    p
      ..oval(
        Rect.fromCenter(
          center: const Offset(0, 0.14),
          width: 0.88,
          height: 0.4,
        ),
        const Color(0xFFEFE6D6),
      )
      ..path(
        Path()
          ..moveTo(-0.26, 0.08)
          ..quadraticBezierTo(-0.2, -0.26, 0.02, -0.26)
          ..quadraticBezierTo(0.24, -0.26, 0.28, 0.08)
          ..close(),
        const Color(0xFF8C4326),
      );
  },

  // --- Extras ---
  'baklava': (p) {
    p
      ..path(
        Path()
          ..moveTo(0, -0.36)
          ..lineTo(0.44, 0)
          ..lineTo(0, 0.36)
          ..lineTo(-0.44, 0)
          ..close(),
        const Color(0xFFE0A93A),
      )
      ..dot(Offset.zero, 0.09, const Color(0xFF4E8A3C));
  },
  'kola': (p) {
    p
      ..bar(
        Rect.fromCenter(
          center: const Offset(0, 0.12),
          width: 0.42,
          height: 0.56,
        ),
        const Color(0xFF43220F),
        radius: 0.13,
      )
      ..bar(
        Rect.fromCenter(
          center: const Offset(0, -0.28),
          width: 0.18,
          height: 0.26,
        ),
        const Color(0xFF43220F),
        radius: 0.04,
      )
      ..bar(
        Rect.fromCenter(
          center: const Offset(0, -0.38),
          width: 0.24,
          height: 0.12,
        ),
        const Color(0xFFD8462F),
        radius: 0.03,
      );
  },
  'ayran': (p) => _glass(p, const Color(0xFFF7F3EA), foam: true),
  'salgam': (p) => _glass(p, const Color(0xFF7E1D2B)),

  // --- Meat, wherever it has to be named ---
  'et': (p) {
    p.stroke(
      Path()
        ..moveTo(-0.4, 0.34)
        ..lineTo(0.4, -0.34),
      const Color(0xFF9A9A9A),
      0.06,
    );
    for (final at in const [
      Offset(-0.2, 0.17),
      Offset.zero,
      Offset(0.2, -0.17),
    ]) {
      p.bar(
        Rect.fromCenter(center: at, width: 0.3, height: 0.22),
        const Color(0xFF8C4326),
        turn: -0.7,
        radius: 0.07,
      );
    }
  },
};

void _glass(_Pen p, Color fill, {bool foam = false}) {
  p.path(
    Path()
      ..moveTo(-0.24, -0.36)
      ..lineTo(0.24, -0.36)
      ..lineTo(0.18, 0.38)
      ..lineTo(-0.18, 0.38)
      ..close(),
    fill,
  );
  if (foam) {
    p.oval(
      Rect.fromCenter(
        center: const Offset(0, -0.34),
        width: 0.46,
        height: 0.14,
      ),
      const Color(0xFFFFFFFF),
      outline: false,
    );
  }
}
