import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/gesture.dart';

/// The one part of the input path a widget test cannot reach — it needs a live
/// game loop and a real pointer — so it is arithmetic here and tested here.
void main() {
  TouchKind kind(Offset start, Offset end, {double? travel}) => classifyTouch(
    start: start,
    end: end,
    maxTravel: travel ?? (end - start).distance,
  );

  group('a finished touch', () {
    test('that barely moved is a tap, however long it was held', () {
      expect(kind(Offset.zero, const Offset(3, -4)), TouchKind.tap);
    });

    test('that went out and came back is not a tap', () {
      // Zero displacement, but the player carried something across the counter
      // and thought better of it. Reading that as a tap would place it.
      expect(
        kind(Offset.zero, Offset.zero, travel: 90),
        TouchKind.drag,
      );
    });

    test('that travelled sideways is a drag', () {
      expect(kind(Offset.zero, const Offset(120, 10)), TouchKind.drag);
    });

    test('that rose more than it slid is a flick', () {
      expect(
        kind(const Offset(400, 400), const Offset(410, 340)),
        TouchKind.flick,
      );
    });

    test('that rose but slid further is a drag', () {
      expect(
        kind(const Offset(400, 400), const Offset(500, 340)),
        TouchKind.drag,
      );
    });

    test('that fell is a drag, never a flick', () {
      expect(
        kind(const Offset(400, 400), const Offset(405, 500)),
        TouchKind.drag,
      );
    });
  });

  test('the travel high-water mark only ever grows', () {
    var travel = 0.0;
    travel = furthest(travel, Offset.zero, const Offset(60, 0));
    travel = furthest(travel, Offset.zero, const Offset(10, 0));
    expect(travel, 60);
  });
}
