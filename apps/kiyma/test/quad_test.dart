import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/core/quad.dart';

void main() {
  group('Quad', () {
    final square = Quad.fromRect(const Rect.fromLTWH(0, 0, 100, 50));

    // The grill is drawn as a rotated diamond; its "top edge" runs down and
    // to the right, which is what every placement is measured against.
    const leaning = Quad(
      Offset(200, 350),
      Offset(300, 420),
      Offset(160, 500),
      Offset(60, 420),
    );

    test('measures width and height along its own edges', () {
      expect(square.width, 100);
      expect(square.height, 50);
      expect(leaning.width, closeTo(122.07, 0.01));
      expect(leaning.height, closeTo(156.52, 0.01));
    });

    test('holds points inside and rejects points in the bounding box', () {
      expect(leaning.contains(leaning.center), isTrue);
      // Top-left of the bounding box, well outside the diamond itself.
      expect(leaning.bounds.contains(const Offset(61, 351)), isTrue);
      expect(leaning.contains(const Offset(61, 351)), isFalse);
    });

    test('splits a wide area side by side and a tall one in a stack', () {
      final wide = square.slots(2);
      expect(wide[0].center.dx, lessThan(wide[1].center.dx));
      expect(wide[0].center.dy, wide[1].center.dy);

      final tall = Quad.fromRect(const Rect.fromLTWH(0, 0, 50, 200)).slots(2);
      expect(tall[0].center.dy, lessThan(tall[1].center.dy));
    });

    test('honours the slot direction override', () {
      final forced = square.slots(2, horizontal: false);
      expect(forced[0].center.dy, lessThan(forced[1].center.dy));
    });

    test('stacked slots widen towards the front', () {
      final stack = Quad.fromRect(const Rect.fromLTWH(0, 0, 50, 200)).slots(4);
      expect(stack.first.width, lessThan(stack.last.width));
    });

    test('slots of a leaning area lean with it', () {
      final slots = leaning.slots(4);
      expect(slots, hasLength(4));
      for (final slot in slots) {
        expect(leaning.contains(slot.center), isTrue);
      }
      expect(slots.first.angle, closeTo(leaning.angle, 0.001));
    });

    test('travels corner by corner between two places', () {
      final half = Quad.between(square, leaning, 0.5);
      expect(half.topLeft, Offset.lerp(square.topLeft, leaning.topLeft, 0.5));
      expect(Quad.between(square, leaning, 0).center, square.center);
      expect(Quad.between(square, leaning, 1).center, leaning.center);
    });

    test('shifts without changing shape', () {
      final moved = leaning.shift(const Offset(10, -20));
      expect(moved.width, closeTo(leaning.width, 0.001));
      expect(moved.center, leaning.center + const Offset(10, -20));
    });

    test('a single slot is the area itself', () {
      expect(square.slots(1).single.center, square.center);
    });
  });
}
