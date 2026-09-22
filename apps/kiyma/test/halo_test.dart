import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/halo.dart';

import 'support/scene_from_disk.dart';

/// The glows are baked at startup, so nothing checks them at runtime: a name
/// that stopped matching a region would simply stop glowing, silently.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets art;
  late Halos halos;

  setUpAll(() async {
    scene = sceneFromDisk();
    art = await GameAssets.load();
    halos = await Halos.bake(scene, art);
  });

  test('every hint and every gold pile has one', () {
    const hints = [
      'malzeme_kiyma',
      'lavas_kaynak',
      'kagit_kaynak',
    ];
    for (final name in hints) {
      expect(halos[name], isNotNull, reason: name);
    }

    final places = scene['altin_alani'].slots.length;
    for (var slot = 0; slot < places; slot++) {
      for (final asset in CoinPile.tipler) {
        final key = Halos.goldKey(asset, slot);
        expect(halos[key], isNotNull, reason: key);
      }
    }

    expect(halos.length, hints.length + places * CoinPile.tipler.length);
  });

  test('each one is its region plus room for the blur to spread', () {
    final tray = scene['malzeme_kiyma'].quad.bounds;
    final baked = halos['malzeme_kiyma']!;
    expect(baked.width, (tray.width + Halos.pad * 2).ceil());
    expect(baked.height, (tray.height + Halos.pad * 2).ceil());
  });
}
