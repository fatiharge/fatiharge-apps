import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/model/carried.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/products.dart';

void main() {
  group('what the hand can hold', () {
    test('each source says where it came from and what to draw', () {
      expect(const CigKiyma().origin, 'malzeme_kiyma');
      expect(const CigKiyma().asset, 'sis_cig');
      expect(const Lavas().origin, 'lavas_kaynak');
      expect(const Lavas().asset, 'lavas_tek');
      expect(const Kagit().origin, 'kagit_kaynak');
      expect(const Kagit().asset, 'kagit_alani');
      expect(const MalzemeTutami(Malzeme.tursu).origin, 'malzeme_tursu');
      expect(const MalzemeTutami(Malzeme.tursu).asset, 'tursu_porsiyon');
      expect(const BilesenTutami(Bilesen.pilav).origin, 'malzeme_pilav');
      expect(
        const BilesenTutami(Bilesen.pilav).asset,
        'bulgur_pilavi_porsiyon',
      );
    });

    test('meat off the grill knows which slot, and whether it is ruined', () {
      expect(const PismisEt(2).origin, 'mangal_alani');
      expect(const PismisEt(2).asset, 'adana_pismis');
      expect(const PismisEt(2, yanik: true).asset, 'sis_yanmis');
    });

    test('a jug is poured; a bottle is carried whole', () {
      expect(const Surahi(Icecek.ayran).origin, 'surahi_ayran');
      expect(const Surahi(Icecek.ayran).asset, 'surahi_ayran');
      expect(Icecek.kola.poured, isFalse);
      expect(Icecek.kola.sourceRegion, 'kola_kaynak');
      expect(Icecek.kola.servedAsset, 'kola_sise');
    });

    test('a finished product knows the shelf it belongs on', () {
      expect(DurumUrun(Durum()).beklemeBolgesi, 'durum_bekleme');
      expect(PorsiyonUrun(Porsiyon()).beklemeBolgesi, 'tabak_birakma');
      expect(const TatliUrun(Tatli.kunefe).beklemeBolgesi, isNull);
      expect(
        const IcecekUrun(Icecek.salgam).beklemeBolgesi,
        'bardak_bekletme',
      );
      expect(const IcecekUrun(Icecek.kola).beklemeBolgesi, isNull);
    });

    test('what is drawn under the finger matches what is held', () {
      expect(
        HazirUrun(DurumUrun(Durum()), 'durum_hazirlama').asset,
        'doner_bekleme',
      );
      expect(
        HazirUrun(PorsiyonUrun(Porsiyon()), 'tabak_hazirlama').asset,
        'porsiyon_hazirlama',
      );
      expect(
        const HazirUrun(TatliUrun(Tatli.sutlac), 'tatli_sutlac').asset,
        'sutlac',
      );
      expect(
        const HazirUrun(IcecekUrun(Icecek.ayran), 'bardak_bekletme').asset,
        'ayran',
      );
    });
  });
}
