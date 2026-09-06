import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/domain/scene.dart';

/// Where every price tag hangs, worked out once for both readers.
///
/// The painter draws these and the page hit-tests them. It used to be the
/// painter's private arithmetic and the page tested the region instead,
/// which meant a tag lifted clear of a neighbour was a tag nothing could
/// touch — and the ingredient wells are small enough that the tag is the
/// only target worth aiming at.
class TagLayout {
  const TagLayout._(this.tags);

  factory TagLayout.of(SceneData scene, Map<String, int> prices) {
    final sorted = prices.keys.toList()
      ..sort((a, b) {
        final ax = scene.maybe(a)?.quad.bounds.center.dx ?? 0;
        final bx = scene.maybe(b)?.quad.bounds.center.dx ?? 0;
        return ax.compareTo(bx);
      });

    final out = <({String region, Rect rect, int price})>[];
    for (final name in sorted) {
      final region = scene.maybe(name);
      if (region == null) continue;
      final price = prices[name]!;
      var rect = _place(scene, region);
      // Two rows at most: anything higher stops reading as belonging to the
      // thing underneath it, however long the string is.
      var lifts = 0;
      while (lifts < 2 &&
          out.any((other) => other.rect.overlaps(rect.inflate(2)))) {
        rect = rect.translate(0, 34);
        lifts++;
      }
      out.add((region: name, rect: rect, price: price));
    }
    return TagLayout._(out);
  }

  final List<({String region, Rect rect, int price})> tags;

  /// One size for every tag, narrow enough to hang between two wells.
  ///
  /// It used to grow with the price, which made a three-figure tag wider than
  /// the 52px well it belonged to. Neighbours overlapped, every one of them
  /// was lifted clear of the last, and the ingredient row came out as a
  /// staircase of dockets pointing at the wrong pots.
  static const size = 48.0;

  static Rect _place(SceneData scene, SceneRegion region) {
    final bounds = region.quad.bounds;
    final x = bounds.center.dx.clamp(
      size / 2 + 2,
      scene.size.width - size / 2 - 2,
    );
    // On the front lip, the way a display case is labelled. Hung above on a
    // string it read as floating — a tag on a low tray or a big grill ended
    // up over bare wall — and sitting on the top edge it covered the one
    // thing the player is there to look at.
    // Overlapping the lip by a third of the thing's own height, so a deep
    // tray keeps its tag tucked against it and a plate of baklava — shorter
    // than the tag itself — is not covered by its own price.
    final bindirme = math.min(size * 0.6, bounds.height * 0.35);
    final y = math.min(
      scene.size.height - size / 2 - 4,
      bounds.bottom + size / 2 - bindirme,
    );
    return Rect.fromCenter(
      center: Offset(x, math.max<double>(size / 2 + 4, y)),
      width: size,
      height: size,
    );
  }

  /// The region whose tag [point] landed on. Inflated because a finger is
  /// wider than a docket.
  String? at(Offset point) {
    for (final tag in tags) {
      if (tag.rect.inflate(6).contains(point)) return tag.region;
    }
    return null;
  }
}
