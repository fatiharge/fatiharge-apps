import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/presentation/gold_text.dart';

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
      var rect = _place(scene, region, price);
      var lifts = 0;
      while (lifts < 6 &&
          out.any((other) => other.rect.overlaps(rect.inflate(2)))) {
        rect = rect.translate(0, -30);
        lifts++;
      }
      out.add((region: name, rect: rect, price: price));
    }
    return TagLayout._(out);
  }

  final List<({String region, Rect rect, int price})> tags;

  static Rect _place(SceneData scene, SceneRegion region, int price) {
    final bounds = region.quad.bounds;
    // Near enough square: the tag art is a paper docket with a loop of
    // string above it, and the loop is most of what makes it read as a tag.
    final width = 30.0 + goldText(price).length * 10;
    final x = bounds.center.dx.clamp(
      width / 2 + 2,
      scene.size.width - width / 2 - 2,
    );
    return Rect.fromCenter(
      center: Offset(x, math.max<double>(28, bounds.top - 26)),
      width: width,
      height: width,
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
