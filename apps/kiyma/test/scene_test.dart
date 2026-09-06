import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/scene.dart';

import 'support/scene_from_disk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;

  setUp(() => scene = sceneFromDisk());

  group('scene.json', () {
    test('is in the 1024x576 space every coordinate was measured in', () {
      expect(scene.size.width, 1024);
      expect(scene.size.height, 576);
    });

    test('names every region the game reaches for', () {
      const named = [
        'malzeme_kiyma',
        'lavas_kaynak',
        'kagit_kaynak',
        'mangal_alani',
        'durum_hazirlama',
        'bekleme_alani',
        'tabak_kaynak',
        'tabak_hazirlama',
        'bardak_kaynak',
        'bardak_bekletme',
        'musteri_slot_1',
        'musteri_slot_3',
      ];
      for (final name in named) {
        expect(scene.maybe(name), isNotNull, reason: name);
      }
      for (final malzeme in Ingredient.values) {
        expect(scene.maybe(malzeme.region), isNotNull, reason: malzeme.region);
      }
      for (final bilesen in PlateItem.values) {
        expect(scene.maybe(bilesen.region), isNotNull, reason: bilesen.region);
      }
      for (final tatli in Dessert.values) {
        expect(scene.maybe(tatli.region), isNotNull, reason: tatli.region);
      }
      for (final icecek in Drink.values) {
        expect(scene.maybe(icecek.sourceRegion), isNotNull);
      }
    });

    test('every referenced image ships', () async {
      for (final name in scene.itemAssets) {
        await expectLater(
          rootBundle.load('assets/items/$name.png'),
          completes,
          reason: name,
        );
      }
    });

    test('the wrap and plate recipes cover their whole ingredient set', () {
      final durum = scene['durum_hazirlama'].composition!;
      expect(durum.ingredient('et'), isNotNull);
      expect(durum.finished, isNotNull);
      for (final malzeme in Ingredient.values) {
        expect(durum.ingredient(malzeme.id), isNotNull, reason: malzeme.id);
      }

      final tabak = scene['tabak_hazirlama'].composition!;
      expect(tabak.ingredient('lavas'), isNotNull);
      expect(tabak.ingredient('et'), isNotNull);
      for (final bilesen in PlateItem.values) {
        expect(tabak.ingredient(bilesen.id), isNotNull, reason: bilesen.id);
      }
    });

    test('capacities match what the design doc asks for', () {
      expect(scene['mangal_alani'].capacity, 4);
      expect(scene['bekleme_alani'].capacity, 3);
      expect(scene['bardak_bekletme'].capacity, 3);
    });

    test('regions do not sit on top of one another at their centres', () {
      // The counter surface and its top edge are the backdrop everything else
      // is laid on, so they are allowed to swallow other centres.
      const backdrop = {'tezgah_bos_yuzey', 'tezgah_ust_kenari'};
      for (final region in scene.interactive) {
        if (backdrop.contains(region.name)) continue;
        final overlapping = scene.interactive.where(
          (other) =>
              other.name != region.name &&
              !backdrop.contains(other.name) &&
              other.quad.contains(region.quad.center),
        );
        expect(overlapping, isEmpty, reason: region.name);
      }
    });
  });
}
