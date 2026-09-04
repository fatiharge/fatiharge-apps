import 'dart:ui';

import 'package:kiyma/core/quad.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/render/painter.dart';

/// The blurred silhouettes a hint glows with, drawn once at startup.
///
/// The glow follows the asset's own shape rather than its region box, which
/// means a mask blur over the image. Doing that live cost three blurred draws
/// a frame for every lit hint — up to six at once, and always at the moment
/// the player has stalled, which is the worst moment to drop a frame. None of
/// the shapes ever change, so they are rendered here instead and the frame
/// only ever blits one.
class Halos {
  const Halos(this._baked);

  /// Room around each silhouette for the blur to spread into.
  static const pad = 26.0;

  static const _colour = Color(0xFFFF8A1F);
  static const _sigma = 10.0;

  /// Everything that can glow: the sources the counter nags with, and the
  /// three gold piles in each of the places a customer can pay at.
  static Iterable<(String key, String asset, Quad quad, AssetFit fit)> targets(
    SceneData scene,
  ) sync* {
    for (final name in const [
      'malzeme_kiyma',
      'lavas_kaynak',
      'kagit_kaynak',
      'cop_alani',
    ]) {
      final region = scene.maybe(name);
      final asset = region?.asset;
      if (region == null || asset == null) continue;
      yield (name, asset, region.quad, region.fit);
    }

    final ledge = scene.maybe('altin_alani');
    if (ledge == null) return;
    final slots = ledge.slots;
    for (var i = 0; i < slots.length; i++) {
      for (final asset in Altin.tipler) {
        yield ('$asset@$i', asset, slots[i], AssetFit.alt);
      }
    }
  }

  static String goldKey(String asset, int slot) => '$asset@$slot';

  static Future<Halos> bake(SceneData scene, GameAssets art) async {
    final paint = Paint()
      ..colorFilter = const ColorFilter.mode(_colour, BlendMode.srcIn)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _sigma)
      ..filterQuality = FilterQuality.medium;

    final baked = <String, Image>{};
    for (final (key, asset, quad, fit) in targets(scene)) {
      final image = art[asset];
      if (image == null) continue;
      final bounds = quad.bounds;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      // The quad carries the lean, so the rotation is baked in and the frame
      // can blit the result axis-aligned.
      final local = quad.shift(-bounds.topLeft + const Offset(pad, pad));
      // Three passes, as the live version had: one is too faint to find on a
      // busy counter, and the build-up is not reproducible by raising alpha.
      for (var i = 0; i < 3; i++) {
        drawInQuad(canvas, image, local, fit, paint: paint);
      }
      baked[key] = await recorder.endRecording().toImage(
        (bounds.width + pad * 2).ceil(),
        (bounds.height + pad * 2).ceil(),
      );
    }
    return Halos(baked);
  }

  final Map<String, Image> _baked;

  int get length => _baked.length;

  Image? operator [](String key) => _baked[key];
}
