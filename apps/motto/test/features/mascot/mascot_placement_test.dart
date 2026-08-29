import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/application/mascot_placement.dart';

void main() {
  const box = Size(400, 800);
  const safe = EdgeInsets.only(top: 40, bottom: 20);
  final bounds = MascotPlacement.boundsIn(box, safe);

  test('the area keeps clear of the insets and its own size', () {
    expect(bounds.left, 8);
    expect(bounds.top, 48);
    expect(bounds.right, 400 - MascotPlacement.size - 8);
    expect(bounds.bottom, 800 - 20 - MascotPlacement.size - 8);
  });

  test('unplaced, it rests in from the far edge', () {
    final at = MascotPlacement.resolved(null, bounds);

    // Read from the far edge, so the resting spot survives a rotation.
    expect(at.dx, bounds.right + MascotPlacement.home.dx);
    expect(at.dy, bounds.bottom + MascotPlacement.home.dy);
  });

  test('placed, it stays where it was put', () {
    expect(
      MascotPlacement.resolved(const Offset(50, 60), bounds),
      const Offset(50, 60),
    );
  });

  test('a drag cannot take it off the screen', () {
    final at = MascotPlacement.draggedTo(
      const Offset(50, 60),
      const Offset(-9999, 9999),
      bounds,
    );

    expect(at.dx, bounds.left);
    expect(at.dy, bounds.bottom);
  });

  test('let go, it settles against the nearer side at the same height', () {
    final near = MascotPlacement.settledFrom(const Offset(20, 300), bounds);
    final far = MascotPlacement.settledFrom(const Offset(280, 300), bounds);

    expect(near.dx, bounds.left);
    expect(far.dx, bounds.right);
    expect(near.dy, 300);
  });

  test('a named spot is a fraction of the area', () {
    expect(
      MascotPlacement.spotIn(Alignment.topLeft, bounds),
      Offset(bounds.left, bounds.top),
    );
    expect(
      MascotPlacement.spotIn(Alignment.bottomRight, bounds),
      Offset(bounds.right, bounds.bottom),
    );
  });
}
