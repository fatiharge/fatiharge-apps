import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

/// Every image the game draws, decoded once at startup.
///
/// The whole `assets/items` folder is loaded, not the subset `scene.json`
/// happens to name. Most of the art is reached only from code — the four
/// grill states, the filled glasses, the wrapped wrap — and a scene-driven
/// list quietly leaves those out, which shows up as an empty grill rather
/// than as an error. The set is 12 MB; there is nothing to gain by trimming
/// it.
class GameAssets {
  GameAssets(this._images);

  /// Folders whose contents are game art, and how a file in each is named.
  /// Items are addressed by their stem (`sis_cig`); the two painted scene
  /// files keep their extension, which is how `scene.json` refers to them.
  static const _items = 'assets/items/';
  static const _scene = 'assets/scene/';

  static Future<GameAssets> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = manifest.listAssets().where(
      (p) => p.startsWith(_items) || p.startsWith(_scene),
    );

    // Flame's cache prefixes `assets/images/`; this project keeps art in two
    // folders of its own, so the prefix is dropped and paths are given whole.
    final images = Images(prefix: '');
    final loaded = <String, Image>{};
    await Future.wait([
      for (final path in paths)
        images.load(path).then((image) => loaded[_key(path)] = image),
    ]);
    return GameAssets(loaded);
  }

  static String _key(String path) {
    final name = path.split('/').last;
    return path.startsWith(_items) ? name.split('.').first : name;
  }

  final Map<String, Image> _images;

  Iterable<String> get names => _images.keys;

  Image? operator [](String name) => _images[name];
}
