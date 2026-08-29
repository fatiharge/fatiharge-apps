import 'package:flutter/painting.dart';

/// Where the mascot may sit, and where it goes when let go.
///
/// Pure geometry, kept out of the widget so it can be reasoned about — and
/// argued with — without pumping frames. Every complaint about the mascot so
/// far has been about one of these numbers.
abstract final class MascotPlacement {
  static const size = 96.0;

  /// Kept clear of the edges so it never sits under a notch or half off the
  /// bottom.
  static const margin = 8.0;

  /// Where it sits when nobody has moved it, measured in from the far edge so
  /// the resting spot survives a rotation.
  static const home = Offset(-16, -180);

  /// The area it may occupy inside [box], once the system insets are taken
  /// out.
  static Rect boundsIn(Size box, EdgeInsets safe) => Rect.fromLTRB(
    safe.left + margin,
    safe.top + margin,
    box.width - safe.right - size - margin,
    box.height - safe.bottom - size - margin,
  );

  /// [at] if it has been placed, otherwise the resting spot.
  static Offset resolved(Offset? at, Rect bounds) =>
      at ??
      Offset(
        home.dx < 0 ? bounds.right + home.dx : home.dx,
        home.dy < 0 ? bounds.bottom + home.dy : home.dy,
      );

  /// Dragged by [delta], never off the screen.
  static Offset draggedTo(Offset from, Offset delta, Rect bounds) {
    final at = from + delta;
    return Offset(
      at.dx.clamp(bounds.left, bounds.right),
      at.dy.clamp(bounds.top, bounds.bottom),
    );
  }

  /// The nearer side, at the same height.
  ///
  /// Left in the middle it covers what somebody is reading; against an edge it
  /// is still reachable and out of the way.
  static Offset settledFrom(Offset at, Rect bounds) {
    final toLeft = (at.dx - bounds.left).abs();
    final toRight = (bounds.right - at.dx).abs();
    return Offset(toLeft < toRight ? bounds.left : bounds.right, at.dy);
  }

  /// The fraction of [bounds] a named spot stands for.
  static Offset spotIn(Alignment alignment, Rect bounds) => Offset(
    bounds.left + (alignment.x + 1) / 2 * bounds.width,
    bounds.top + (alignment.y + 1) / 2 * bounds.height,
  );
}
