import 'dart:math' as math;
import 'dart:ui';

/// A scene region, kept as four corners rather than a rectangle.
///
/// The kitchen is painted with a wide lens, so counter areas lean: their top
/// and bottom edges are not parallel and the sides are not vertical. A
/// bounding box around one of those catches taps that landed on its
/// neighbour, and an asset fitted to the box sits visibly off the surface.
/// Everything here therefore works in the quad's own axes — width along the
/// top edge, height along the left edge, angle from the top edge's slope.
class Quad {
  const Quad(this.topLeft, this.topRight, this.bottomRight, this.bottomLeft);

  factory Quad.fromJson(List<dynamic> corners) {
    Offset at(int i) {
      final pair = (corners[i] as List<dynamic>).cast<num>();
      return Offset(pair[0].toDouble(), pair[1].toDouble());
    }

    return Quad(at(0), at(1), at(2), at(3));
  }

  /// Part of the way from [a] to [b], corner by corner.
  factory Quad.between(Quad a, Quad b, double t) => Quad(
    Offset.lerp(a.topLeft, b.topLeft, t)!,
    Offset.lerp(a.topRight, b.topRight, t)!,
    Offset.lerp(a.bottomRight, b.bottomRight, t)!,
    Offset.lerp(a.bottomLeft, b.bottomLeft, t)!,
  );

  /// An axis-aligned quad, for regions that were never measured as one.
  factory Quad.fromRect(Rect rect) => Quad(
    rect.topLeft,
    rect.topRight,
    rect.bottomRight,
    rect.bottomLeft,
  );

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  List<Offset> get corners => [topLeft, topRight, bottomRight, bottomLeft];

  /// Width measured along the top edge, not across the bounding box.
  double get width => (topRight - topLeft).distance;

  /// Height measured along the left edge.
  double get height => (bottomLeft - topLeft).distance;

  /// The top edge's slope, in radians. Assets are rotated by this.
  double get angle {
    final edge = topRight - topLeft;
    return math.atan2(edge.dy, edge.dx);
  }

  Offset get center => Offset(
    (topLeft.dx + topRight.dx + bottomRight.dx + bottomLeft.dx) / 4,
    (topLeft.dy + topRight.dy + bottomRight.dy + bottomLeft.dy) / 4,
  );

  Rect get bounds {
    final xs = corners.map((c) => c.dx);
    final ys = corners.map((c) => c.dy);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  /// Bilinear interpolation across the quad. `u` runs left to right, `v` top
  /// to bottom, both `0..1`.
  Offset at(double u, double v) {
    final top = Offset.lerp(topLeft, topRight, u)!;
    final bottom = Offset.lerp(bottomLeft, bottomRight, u)!;
    return Offset.lerp(top, bottom, v)!;
  }

  /// A sub-quad of the `u,v` rectangle. Corners are interpolated, so a slot
  /// carved out of a leaning region leans with it.
  Quad sub(double u0, double v0, double u1, double v1) =>
      Quad(at(u0, v0), at(u1, v0), at(u1, v1), at(u0, v1));

  /// Whether [point] is inside, by winding across the four edges. Convex or
  /// not, every region here is a simple quad, so the sign test holds.
  bool contains(Offset point) {
    var positive = false;
    var negative = false;
    for (var i = 0; i < 4; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % 4];
      final cross =
          (b.dx - a.dx) * (point.dy - a.dy) - (b.dy - a.dy) * (point.dx - a.dx);
      if (cross > 0) positive = true;
      if (cross < 0) negative = true;
      if (positive && negative) return false;
    }
    return true;
  }

  Quad shift(Offset by) => Quad(
    topLeft + by,
    topRight + by,
    bottomRight + by,
    bottomLeft + by,
  );

  Path toPath() => Path()
    ..moveTo(topLeft.dx, topLeft.dy)
    ..lineTo(topRight.dx, topRight.dy)
    ..lineTo(bottomRight.dx, bottomRight.dy)
    ..lineTo(bottomLeft.dx, bottomLeft.dy)
    ..close();

  /// Bands that overlap, each [ratio] of the region tall.
  ///
  /// A shelf deep enough to hold four wraps at a legible size does not exist
  /// on this counter, so they lean on each other the way they would in a real
  /// warmer: full size, offset, the front one whole and the rest showing
  /// their top edge.
  List<Quad> stack(int count, double ratio) {
    if (count <= 1) return [sub(0, 1 - ratio, 1, 1)];
    final step = (1 - ratio) / (count - 1);
    return [
      for (var i = 0; i < count; i++) sub(0, i * step, 1, i * step + ratio),
    ];
  }

  /// Splits the region into [count] slots.
  ///
  /// The direction follows the long axis — a wide area seats items side by
  /// side, a tall one stacks them — unless [horizontal] overrides it. Stacked
  /// slots widen from 88% to 100% down the region so the back of a stack
  /// reads as further away, which the flat art does not say on its own.
  List<Quad> slots(int count, {bool? horizontal}) {
    if (count <= 1) return [this];
    final sideways = horizontal ?? width >= height;
    return [
      for (var i = 0; i < count; i++)
        if (sideways)
          sub(i / count, 0, (i + 1) / count, 1)
        else
          _stacked(i, count),
    ];
  }

  Quad _stacked(int index, int count) {
    final v0 = index / count;
    final v1 = (index + 1) / count;
    // Perspective: the near (lower) slots are drawn a little wider.
    double inset(double v) => (1 - lerpDouble(0.88, 1, v)!) / 2;
    final i0 = inset(v0);
    final i1 = inset(v1);
    return Quad(at(i0, v0), at(1 - i0, v0), at(1 - i1, v1), at(i1, v1));
  }
}
