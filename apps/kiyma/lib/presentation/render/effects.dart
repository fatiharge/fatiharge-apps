import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/painter.dart';

/// Where in the draw order an effect belongs.
enum EffectLayer {
  /// Behind the food and the people: smoke off the grill, heat.
  room,

  /// Over the counter but under the instrument: bursts, coins, flying items.
  counter,

  /// Over everything: numbers that must never be hidden.
  over,
}

/// A pool of short-lived drawings.
///
/// The counter had nowhere to put an effect: one `render` of a dozen fixed
/// passes, no tween, no particle, no seam to shake. This is that place. It
/// holds no Flame and no widgets — an effect is age, life and a draw call —
/// so it tests without a canvas, and everything is spawned from the renderer
/// rather than from the rules, which stay engine-free.
class Effects {
  Effects(this.art, {math.Random? random}) : _random = random ?? math.Random();

  final GameAssets art;
  final math.Random _random;
  final List<_Effect> _live = [];

  /// Past this the pool refuses to grow. A frame that wanted more than this
  /// wanted a different effect.
  static const cap = 220;

  int get length => _live.length;

  void clear() => _live.clear();

  void update(double dt) {
    for (final effect in _live) {
      effect.age += dt;
    }
    _live.removeWhere((e) => e.age >= e.life);
  }

  void render(Canvas canvas, EffectLayer layer) {
    for (final effect in _live) {
      if (effect.layer == layer) effect.draw(canvas, this);
    }
  }

  void _add(_Effect effect) {
    if (_live.length >= cap) return;
    _live.add(effect);
  }

  double _spread(double range) => (_random.nextDouble() * 2 - 1) * range;

  double _between(double from, double to) =>
      from + _random.nextDouble() * (to - from);

  // --- what the counter can ask for ---

  /// A drifting cloud: smoke off a skewer, steam off a fresh wrap.
  void puff({
    required Offset at,
    required String asset,
    Color tint = const Color(0xFFFFFFFF),
    double life = 2,
    double from = 14,
    double to = 46,
    double rise = 74,
    double sway = 16,
    double peak = 0.55,
    double floor = 120,
    EffectLayer layer = EffectLayer.room,
  }) => _add(
    _Puff(
      at: at + Offset(_spread(7), 0),
      asset: asset,
      tint: tint,
      life: life,
      from: from,
      to: to,
      rise: rise,
      sway: sway,
      phase: _random.nextDouble() * math.pi * 2,
      peak: peak,
      floor: floor,
      layer: layer,
    ),
  );

  /// A fan of specks thrown out of a point. The shape of a hit.
  void burst({
    required Offset at,
    required Color colour,
    int count = 14,
    double speed = 240,
    double spread = 2.1,
    double up = -math.pi / 2,
    double gravity = 500,
    double life = 0.5,
    String? asset,
  }) {
    for (var i = 0; i < count; i++) {
      final angle = up + _spread(spread / 2);
      final v = speed * _between(0.55, 1.35);
      _add(
        _Speck(
          at: at,
          velocity: Offset(math.cos(angle) * v, math.sin(angle) * v),
          gravity: gravity,
          colour: colour,
          size: _between(2.5, 5.5),
          life: life * _between(0.7, 1.25),
          asset: asset,
        ),
      );
    }
  }

  /// A ring going out. Reads as impact on its own, without a sprite.
  void ring({
    required Offset at,
    required Color colour,
    double to = 70,
    double life = 0.26,
    double width = 6,
  }) => _add(_Ring(at: at, colour: colour, to: to, life: life, width: width));

  /// A number leaving the place it was earned.
  void floater({
    required Offset at,
    required String text,
    required Color colour,
    double size = 20,
    double rise = 42,
    double life = 0.9,
  }) => _add(
    _Floater(
      at: at,
      text: text,
      colour: colour,
      size: size,
      rise: rise,
      life: life,
    ),
  );

  /// A thing travelling from where it was picked up to where it landed, so
  /// arrival is the cause of the change rather than 260ms after it.
  void flight({
    required Offset from,
    required Offset to,
    required String asset,
    required double width,
    double life = 0.26,
  }) => _add(
    _Flight(from: from, to: to, asset: asset, width: width, life: life),
  );

  /// Coins going into the till, staggered so they read as a stream.
  void coins({required Offset from, required Offset to, int count = 8}) {
    for (var i = 0; i < count; i++) {
      _add(
        _Coin(
          from: from + Offset(_spread(14), _spread(8)),
          to: to,
          delay: i * 0.03,
          life: _between(0.38, 0.52) + i * 0.03,
        ),
      );
    }
  }
}

abstract class _Effect {
  _Effect({required this.life, required this.layer});

  final double life;
  final EffectLayer layer;
  double age = 0;

  double get t => (age / life).clamp(0.0, 1.0);

  void draw(Canvas canvas, Effects pool);
}

double _ease(double t, Curve curve) => curve.transform(t.clamp(0.0, 1.0));

class _Puff extends _Effect {
  _Puff({
    required this.at,
    required this.asset,
    required this.tint,
    required super.life,
    required this.from,
    required this.to,
    required this.rise,
    required this.sway,
    required this.phase,
    required this.peak,
    required this.floor,
    required super.layer,
  });

  final Offset at;
  final String asset;
  final Color tint;
  final double from;
  final double to;
  final double rise;
  final double sway;
  final double phase;
  final double peak;
  final double floor;

  @override
  void draw(Canvas canvas, Effects pool) {
    final image = pool.art[asset];
    if (image == null) return;
    final width = from + (to - from) * _ease(t, Curves.easeOut);
    final y = at.dy - rise * _ease(t, Curves.easeOutSine);
    final x = at.dx + math.sin(phase + t * 3.1) * sway * t;

    // In fast, out slowly, and thinning as it climbs into open air so the
    // plume never reaches the instrument or the calendar.
    final alpha =
        peak *
        (t < 0.15 ? t / 0.15 : 1 - (t - 0.15) / 0.85) *
        ((y - floor) / 120).clamp(0.0, 1.0);
    if (alpha <= 0.01) return;

    drawCentered(
      canvas,
      image,
      Offset(x, y),
      width,
      paint: Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.mode(
          tint.withValues(alpha: alpha),
          BlendMode.modulate,
        ),
    );
  }
}

class _Speck extends _Effect {
  _Speck({
    required this.at,
    required this.velocity,
    required this.gravity,
    required this.colour,
    required this.size,
    required super.life,
    this.asset,
  }) : super(layer: EffectLayer.counter);

  final Offset at;
  final Offset velocity;
  final double gravity;
  final Color colour;
  final double size;
  final String? asset;

  @override
  void draw(Canvas canvas, Effects pool) {
    final position = at + velocity * age + Offset(0, 0.5 * gravity * age * age);
    final alpha = (1 - t) * (1 - t);

    final sprite = asset == null ? null : pool.art[asset!];
    if (sprite != null) {
      drawCentered(
        canvas,
        sprite,
        position,
        size * 3.4,
        paint: Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(
            colour.withValues(alpha: alpha),
            BlendMode.modulate,
          ),
      );
      return;
    }
    canvas.drawCircle(
      position,
      size * (1 - t * 0.4),
      Paint()..color = colour.withValues(alpha: alpha),
    );
  }
}

class _Ring extends _Effect {
  _Ring({
    required this.at,
    required this.colour,
    required this.to,
    required super.life,
    required this.width,
  }) : super(layer: EffectLayer.counter);

  final Offset at;
  final Color colour;
  final double to;
  final double width;

  @override
  void draw(Canvas canvas, Effects pool) {
    final eased = _ease(t, Curves.easeOutCubic);
    canvas.drawCircle(
      at,
      10 + (to - 10) * eased,
      Paint()
        ..color = colour.withValues(alpha: (1 - eased) * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * (1 - eased) + 0.5,
    );
  }
}

class _Floater extends _Effect {
  _Floater({
    required this.at,
    required this.text,
    required this.colour,
    required this.size,
    required this.rise,
    required super.life,
  }) : super(layer: EffectLayer.over);

  final Offset at;
  final String text;
  final Color colour;
  final double size;
  final double rise;

  @override
  void draw(Canvas canvas, Effects pool) {
    final eased = _ease(t, Curves.easeOutCubic);
    final y = at.dy - rise * eased;
    // Overshoots, settles, then fades: a number that merely appears is not
    // read as a reward.
    final scale = t < 0.25
        ? 0.6 + 0.55 * _ease(t / 0.25, Curves.easeOutBack)
        : 1.0;
    final alpha = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;

    canvas
      ..save()
      ..translate(at.dx, y)
      ..scale(scale)
      ..translate(-at.dx, -y);
    drawText(
      canvas,
      text,
      Offset(at.dx, y),
      size: size,
      weight: 900,
      family: 'Rubik',
      center: true,
      color: colour.withValues(alpha: alpha),
    );
    canvas.restore();
  }
}

class _Flight extends _Effect {
  _Flight({
    required this.from,
    required this.to,
    required this.asset,
    required this.width,
    required super.life,
  }) : super(layer: EffectLayer.counter);

  final Offset from;
  final Offset to;
  final String asset;
  final double width;

  @override
  void draw(Canvas canvas, Effects pool) {
    final image = pool.art[asset];
    if (image == null) return;
    final eased = _ease(t, Curves.easeInOutCubic);
    // A chord with a lift: things carried across a counter travel in an arc.
    final control = Offset.lerp(from, to, 0.5)! - const Offset(0, 55);
    final a = Offset.lerp(from, control, eased)!;
    final b = Offset.lerp(control, to, eased)!;
    final at = Offset.lerp(a, b, eased)!;

    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(0.18 * (1 - eased))
      ..translate(-at.dx, -at.dy);
    drawCentered(canvas, image, at, width * (1.12 - 0.12 * eased));
    canvas.restore();
  }
}

class _Coin extends _Effect {
  _Coin({
    required this.from,
    required this.to,
    required this.delay,
    required super.life,
  }) : super(layer: EffectLayer.counter);

  final Offset from;
  final Offset to;
  final double delay;

  @override
  void draw(Canvas canvas, Effects pool) {
    if (age < delay) return;
    final image = pool.art['altin'];
    if (image == null) return;
    final progress = ((age - delay) / (life - delay)).clamp(0.0, 1.0);
    // Accelerating into the till, so it lands rather than arrives.
    final eased = _ease(progress, Curves.easeInCubic);
    final control = Offset.lerp(from, to, 0.5)! - const Offset(0, 90);
    final a = Offset.lerp(from, control, eased)!;
    final b = Offset.lerp(control, to, eased)!;
    final at = Offset.lerp(a, b, eased)!;

    // Spinning, by squashing horizontally.
    final spin = math.cos(progress * 11).abs().clamp(0.25, 1.0);
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(spin, 1)
      ..translate(-at.dx, -at.dy);
    drawCentered(canvas, image, at, 26 * (1 - progress * 0.35));
    canvas.restore();
  }
}
