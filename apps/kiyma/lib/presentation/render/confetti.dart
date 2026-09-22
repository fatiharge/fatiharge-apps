import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show CustomPainter;

/// A handful of paper thrown over the thing that was just bought.
///
/// Deterministic from a seed and driven by one number, so nothing is stored
/// per particle and nothing runs when [t] is not moving. The animation plays
/// once and stops: a repeating one on this page is a `pumpAndSettle` that
/// never returns.
class ConfettiPainter extends CustomPainter {
  const ConfettiPainter({
    required this.origin,
    required this.t,
    required this.design,
    this.count = 26,
  });

  /// Where it comes from, in scene coordinates.
  final Offset origin;

  /// 0 to 1, the whole life of the burst.
  final double t;
  final Size design;
  final int count;

  static const _renkler = [
    Color(0xFFE8641A),
    Color(0xFFFFC24A),
    Color(0xFF6FA8A0),
    Color(0xFFF7EEDF),
    Color(0xFFB4472E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    canvas
      ..save()
      ..scale(size.width / design.width, size.height / design.height);

    final random = math.Random(7);
    // Fades over the last third only, so the paper is solid while it flies.
    final alpha = t < 0.66 ? 1.0 : (1 - t) / 0.34;
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 60 + random.nextDouble() * 130;
      final spin = random.nextDouble() * math.pi * 4;
      final at =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * speed * t +
          // Gravity, so it falls rather than expanding like a balloon.
          Offset(0, 150 * t * t);
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(spin * t)
        ..drawRect(
          const Rect.fromLTWH(-3.5, -2, 7, 4),
          Paint()
            ..color = _renkler[i % _renkler.length].withValues(alpha: alpha),
        )
        ..restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.t != t || old.origin != origin;
}
