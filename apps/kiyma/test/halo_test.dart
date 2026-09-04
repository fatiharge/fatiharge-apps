import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/halo.dart';
import 'package:kiyma/game/model/products.dart';

/// The glows are baked at startup, so nothing checks them at runtime: a name
/// that stopped matching a region would simply stop glowing, silently.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets art;
  late Halos halos;

  setUpAll(() async {
    scene = await SceneData.load();
    art = await GameAssets.load();
    halos = await Halos.bake(scene, art);
  });

  test('every hint and every gold pile has one', () {
    const hints = [
      'malzeme_kiyma',
      'lavas_kaynak',
      'kagit_kaynak',
      'cop_alani',
    ];
    for (final name in hints) {
      expect(halos[name], isNotNull, reason: name);
    }

    final places = scene['altin_alani'].slots.length;
    for (var slot = 0; slot < places; slot++) {
      for (final asset in Altin.tipler) {
        final key = Halos.goldKey(asset, slot);
        expect(halos[key], isNotNull, reason: key);
      }
    }

    expect(halos.length, hints.length + places * Altin.tipler.length);
  });

  test('each one is its region plus room for the blur to spread', () {
    final tray = scene['malzeme_kiyma'].quad.bounds;
    final baked = halos['malzeme_kiyma']!;
    expect(baked.width, (tray.width + Halos.pad * 2).ceil());
    expect(baked.height, (tray.height + Halos.pad * 2).ceil());
  });
}
