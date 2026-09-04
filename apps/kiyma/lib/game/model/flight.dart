import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/core/quad.dart';

/// Something on its way from one part of the counter to another.
///
/// A wrap that appeared on the shelf the instant it was rolled read as a
/// teleport; watching it travel is what tells the player where it went.
class Flight {
  Flight({
    required this.asset,
    required this.from,
    required this.to,
    required this.region,
    required this.slot,
  });

  static const _duration = 0.4;
  static const _lift = 34.0;

  final String asset;
  final Quad from;
  final Quad to;

  /// Where it lands, so the shelf can leave the slot empty until it arrives.
  final String region;
  final int slot;

  double _elapsed = 0;

  bool get landed => _elapsed >= _duration;

  void tick(double dt) => _elapsed += dt;

  /// Where to draw it now: between the two places, arcing over the counter.
  Quad get quad {
    final t = (_elapsed / _duration).clamp(0.0, 1.0);
    final eased = 1 - math.pow(1 - t, 3).toDouble();
    return Quad.between(
      from,
      to,
      eased,
    ).shift(Offset(0, -math.sin(t * math.pi) * _lift));
  }
}
