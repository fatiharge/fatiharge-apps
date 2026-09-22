import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/model/carried.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/products.dart';

void main() {
  group('what the hand can hold', () {
    test('each source says where it came from and what to draw', () {
      expect(const RawMince().origin, 'malzeme_kiyma');
      expect(const RawMince().asset, 'sis_cig');
      expect(const Flatbread().origin, 'lavas_kaynak');
      expect(const Flatbread().asset, 'lavas_tek');
      expect(const Paper().origin, 'kagit_kaynak');
      expect(const Paper().asset, 'kagit_alani');
      expect(const IngredientHandful(Ingredient.tursu).origin, 'malzeme_tursu');
      expect(const IngredientHandful(Ingredient.tursu).asset, 'tursu_porsiyon');
      expect(const PlateItemHandful(PlateItem.pilav).origin, 'malzeme_pilav');
      expect(
        const PlateItemHandful(PlateItem.pilav).asset,
        'bulgur_pilavi_porsiyon',
      );
    });

    test('meat off the grill knows which slot, and whether it is ruined', () {
      expect(const CookedMeat(2).origin, 'mangal_alani');
      expect(const CookedMeat(2).asset, 'adana_pismis');
      expect(const CookedMeat(2, yanik: true).asset, 'sis_yanmis');
    });

    test('a jug is poured; a bottle is carried whole', () {
      expect(const Jug(Drink.ayran).origin, 'surahi_ayran');
      expect(const Jug(Drink.ayran).asset, 'surahi_ayran');
      expect(Drink.kola.poured, isFalse);
      expect(Drink.kola.sourceRegion, 'kola_kaynak');
      expect(Drink.kola.servedAsset, 'kola_sise');
    });

    test('a finished product knows the shelf it belongs on', () {
      // One shelf for both lines.
      expect(WrapProduct(Wrap()).beklemeBolgesi, 'bekleme_alani');
      expect(PlateProduct(Plate()).beklemeBolgesi, 'bekleme_alani');
      expect(const DessertProduct(Dessert.baklava).beklemeBolgesi, isNull);
      expect(
        const DrinkProduct(Drink.salgam).beklemeBolgesi,
        'bardak_bekletme',
      );
      expect(const DrinkProduct(Drink.kola).beklemeBolgesi, isNull);
    });

    test('everything knows the region that draws it full size', () {
      expect(const RawMince().evi, 'mangal_alani');
      expect(const CookedMeat(0).evi, 'mangal_alani');
      expect(const Flatbread().evi, 'durum_hazirlama');
      expect(const IngredientHandful(Ingredient.tursu).evi, 'malzeme_tursu');
      expect(WrapProduct(Wrap()).evi, 'durum_hazirlama');
      expect(PlateProduct(Plate()).evi, 'tabak_hazirlama');
      expect(const DrinkProduct(Drink.ayran).evi, 'bardak_bekletme');
      expect(const DrinkProduct(Drink.kola).evi, 'kola_kaynak');
    });

    test('what is drawn under the finger matches what is held', () {
      expect(
        FinishedProduct(WrapProduct(Wrap()), 'durum_hazirlama').asset,
        'doner_bekleme',
      );
      expect(
        FinishedProduct(PlateProduct(Plate()), 'tabak_hazirlama').asset,
        'porsiyon_hazirlama',
      );
      expect(
        const FinishedProduct(
          DessertProduct(Dessert.baklava),
          'tatli_baklava',
        ).asset,
        'baklava',
      );
      expect(
        const FinishedProduct(
          DrinkProduct(Drink.ayran),
          'bardak_bekletme',
        ).asset,
        'ayran',
      );
    });
  });
}
