import 'dart:math' as math;
import 'dart:ui';

/// The three things a touch can turn out to have been (design doc 13).
enum TouchKind { tap, drag, flick, none }

/// What a finished touch was, from its geometry alone.
///
/// Pulled out of the Flame callback because that callback is the one part of
/// the input path a test cannot reach: it needs a live game loop and a real
/// pointer. Here it is arithmetic, and the awkward cases have tests.
///
/// [maxTravel] is how far the finger ever got from where it landed, not how
/// far it ended up. A drag out and back to the start has zero displacement
/// and is emphatically not a tap — reading it as one would place whatever the
/// player had just decided not to place.
TouchKind classifyTouch({
  required Offset start,
  required Offset end,
  required double maxTravel,
}) {
  if (maxTravel < tapRadius) return TouchKind.tap;
  final travel = end - start;
  if (travel.dy < flickRise && travel.dy.abs() > travel.dx.abs()) {
    return TouchKind.flick;
  }
  return TouchKind.drag;
}

/// Under this much movement a touch is a tap, however long it was held.
///
/// There is no duration test on purpose. Holding still is not a different
/// intention here — nothing in the game is long-pressed — and a cutoff meant
/// a finger resting a moment too long fell through to the drop path: the
/// pause button went dead and a tap on a tray reported "Olmaz".
const tapRadius = 12.0;

/// A flick has to rise by this much, and rise more than it slides.
const flickRise = -30.0;

/// The running maximum a drag has reached, for [classifyTouch].
double furthest(double soFar, Offset start, Offset now) =>
    math.max(soFar, (now - start).distance);
