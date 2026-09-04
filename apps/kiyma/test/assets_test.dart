import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/products.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameAssets assets;
  setUpAll(() async => assets = await GameAssets.load());

  /// Most of the art is reached from code rather than from `scene.json` — the
  /// four grill states, the full glasses, the wrapped wrap. The renderer skips
  /// an image it cannot find, so a missing one shows up as an empty grill and
  /// not as an error. This is the check that turns that into a failing test.
  test('every image the game asks for by name is loaded', () {
    final wanted = <String>{
      'sis_cig',
      'sis_pisiyor',
      'sis_pismis',
      'sis_yanmis',
      'adana_pismis',
      'lavaslar',
      'lavas_tek',
      'durum_sarili',
      'doner_bekleme',
      'kagit_alani',
      'bos_tabak_yigini',
      'tabak_bos',
      'porsiyon_hazirlama',
      'bos_bardak',
      'bos_bardak_grup',
      'kola_sise',
      'kola_sise_grup',
      'mangal_govde',
      'duvar_saati',
      'cop_kovasi',
      'takvim',
      ...Altin.tipler,
      'back_scene.jpg',
      'base_table.png',
      for (final malzeme in Malzeme.values) ...[
        malzeme.trayAsset,
        malzeme.stripAsset,
        malzeme.portionAsset,
      ],
      for (final bilesen in Bilesen.values) ...[
        bilesen.trayAsset,
        bilesen.portionAsset,
      ],
      for (final tatli in Tatli.values) tatli.asset,
      for (final icecek in Icecek.values) ...[
        icecek.sourceAsset,
        icecek.servedAsset,
      ],
    };

    for (final name in wanted) {
      expect(assets[name], isNotNull, reason: name);
    }
  });

  test('every image the scene points at is loaded', () async {
    final scene = await SceneData.load();
    for (final name in scene.itemAssets) {
      expect(assets[name], isNotNull, reason: name);
    }
  });

  test('nothing unused is shipped', () {
    // The art repository still holds these; the prep script drops them.
    for (final dropped in [
      'kesme_tahtasi',
      'dereotu_tepsi',
      'maydanoz_tepsi',
      'patlican_tepsi',
    ]) {
      expect(assets[dropped], isNull, reason: dropped);
    }
  });
}
