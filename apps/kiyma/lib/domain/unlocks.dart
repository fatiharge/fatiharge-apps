import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';

/// One ladder in the shop.
///
/// The shop used to be seventeen unrelated purchases, most of which added an
/// ingredient — which is more dragging, not more game. A group is a heading
/// and its tiers are rungs bought in order, so "what does the grill do next"
/// is one row instead of five, and the rungs a player cannot reach yet are
/// the ladder they can see.
///
/// Enum order is the order the shop draws them.
enum UnlockGroup {
  mangal('mangal'),
  bicak('bicak'),
  komur('komur'),
  malzeme('malzeme', sirasiz: true),
  bekleme('bekleme'),
  musteri('musteri'),
  ikram('ikram'),
  kasa('kasa'),
  cirak('cirak'),
  tabela('tabela'),
  kasap('kasap'),
  porsiyon('porsiyon', sirasiz: true, hatli: true),
  tatli('tatli', sirasiz: true),
  icecek('icecek', sirasiz: true, hatli: true),
  bardak('bardak', gerek: 'icecek_hatti'),
  ayranSurahisi('ayran_surahisi', gerek: 'icecek_ayran'),
  salgamSurahisi('salgam_surahisi', gerek: 'icecek_salgam');

  const UnlockGroup(
    this.id, {
    this.gerek,
    this.sirasiz = false,
    this.hatli = false,
  });

  /// Names `grup.<id>` in the translations, and nothing else.
  final String id;

  /// A lock nothing in the group sells before. Only the drink shelves need
  /// one: a faster ayran jug means nothing on a counter with no ayran.
  final String? gerek;

  /// Separate goods rather than tiers of one thing. Pickles are not a better
  /// pepper, so the shop offers them all at once and lets the prices decide
  /// the order.
  final bool sirasiz;

  /// The first rung opens the line and the rest sit on it. Only the plate and
  /// the drinks work this way; the ingredients have no door in front of them,
  /// and gating them on the cheapest one kept pickles off the shelf until
  /// peppers were bought.
  final bool hatli;
}

/// One buyable rung: what it opens, what it costs, and where it sits.
class Unlock {
  const Unlock(this.id, this.price, this.grup, this.kademe);

  final String id;
  final int price;
  final UnlockGroup grup;

  /// 1-based. A rung is offered once the one under it is open.
  final int kademe;
}

/// What the shop has open, and what money opens next.
class Unlocks {
  Unlocks() : _open = {..._startOpen} {
    _open.forEach(_say);
  }

  /// Day one: one line, two ingredients, two places. Not markers the shop
  /// sells — they are open before it opens.
  static const _startOpen = {
    'mangal_2',
    'musteri_2',
    'malzeme_domates',
    'malzeme_sogan',
    'bekleme_1',
  };

  /// Every rung, priced against the purse rather than against a day.
  ///
  /// Each one costs a share of everything banked by the day it belongs to,
  /// which is what makes the day it first becomes affordable the day it was
  /// written for. The forty-seven are spread one or two to a day across the
  /// thirty, and each of the heavy days carries exactly one.
  static const catalogue = [
    Unlock('mangal_3', 520, UnlockGroup.mangal, 1),
    Unlock('mangal_4', 1500000, UnlockGroup.mangal, 2),

    Unlock('bicak_1', 2000, UnlockGroup.bicak, 1),
    Unlock('bicak_2', 770000, UnlockGroup.bicak, 2),

    Unlock('komur_1', 54, UnlockGroup.komur, 1),
    Unlock('komur_2', 2200, UnlockGroup.komur, 2),
    Unlock('komur_3', 350000, UnlockGroup.komur, 3),
    Unlock('komur_4', 17000000, UnlockGroup.komur, 4),
    Unlock('komur_5', 830000000, UnlockGroup.komur, 5),

    Unlock('malzeme_biber', 160, UnlockGroup.malzeme, 1),
    Unlock('malzeme_tursu', 9900, UnlockGroup.malzeme, 2),

    Unlock('bekleme_2', 140, UnlockGroup.bekleme, 1),
    Unlock('bekleme_3', 210000, UnlockGroup.bekleme, 2),

    Unlock('musteri_3', 4000, UnlockGroup.musteri, 1),

    Unlock('ikram_1', 27000, UnlockGroup.ikram, 1),
    Unlock('ikram_2', 16000000, UnlockGroup.ikram, 2),
    Unlock('ikram_3', 370000000, UnlockGroup.ikram, 3),

    Unlock('kasa_1', 20000, UnlockGroup.kasa, 1),
    Unlock('kasa_2', 5300000, UnlockGroup.kasa, 2),
    Unlock('kasa_3', 420000000, UnlockGroup.kasa, 3),

    Unlock('cirak_1', 14000, UnlockGroup.cirak, 1),
    Unlock('cirak_2', 3600000, UnlockGroup.cirak, 2),
    Unlock('cirak_3', 150000000, UnlockGroup.cirak, 3),

    Unlock('tabela_1', 190000, UnlockGroup.tabela, 1),
    Unlock('tabela_2', 23000000, UnlockGroup.tabela, 2),
    Unlock('tabela_3', 290000000, UnlockGroup.tabela, 3),

    Unlock('kasap_1', 680, UnlockGroup.kasap, 1),
    Unlock('kasap_2', 1100000, UnlockGroup.kasap, 2),
    Unlock('kasap_3', 98000000, UnlockGroup.kasap, 3),

    Unlock('porsiyon_hatti', 14, UnlockGroup.porsiyon, 1),
    Unlock('bilesen_icli_kofte', 98, UnlockGroup.porsiyon, 2),
    Unlock('bilesen_pilav', 110000, UnlockGroup.porsiyon, 3),
    Unlock('bilesen_patates', 23000000, UnlockGroup.porsiyon, 4),
    Unlock('bilesen_ezme', 43000000, UnlockGroup.porsiyon, 5),

    Unlock('tatli_baklava', 2700, UnlockGroup.tatli, 1),

    Unlock('icecek_hatti', 30, UnlockGroup.icecek, 1),
    Unlock('icecek_salgam', 470, UnlockGroup.icecek, 2),
    Unlock('icecek_ayran', 130000, UnlockGroup.icecek, 3),
    Unlock('icecek_kola', 12000000, UnlockGroup.icecek, 4),

    Unlock('bardak_2', 1300, UnlockGroup.bardak, 1),
    Unlock('bardak_3', 2400000, UnlockGroup.bardak, 2),

    Unlock('surahi_ayran_1', 300000, UnlockGroup.ayranSurahisi, 1),
    Unlock('surahi_ayran_2', 110000000, UnlockGroup.ayranSurahisi, 2),
    Unlock('surahi_ayran_3', 300000000, UnlockGroup.ayranSurahisi, 3),

    Unlock('surahi_salgam_1', 19000, UnlockGroup.salgamSurahisi, 1),
    Unlock('surahi_salgam_2', 62000000, UnlockGroup.salgamSurahisi, 2),
    Unlock('surahi_salgam_3', 240000000, UnlockGroup.salgamSurahisi, 3),
  ];

  static final Map<String, Unlock> _byId = {
    for (final unlock in catalogue) unlock.id: unlock,
  };

  /// Every rung of one ladder, bought and unbought. What the shop draws.
  static List<Unlock> kademeler(UnlockGroup grup) =>
      catalogue.where((unlock) => unlock.grup == grup).toList();

  final Set<String> _open;

  /// How far up each ladder the counter has been bought.
  ///
  /// Counted as ids arrive rather than derived on demand: the coal tier and
  /// the knife's handful count are asked for on every frame, and a catalogue
  /// scan a frame is a scan too many.
  final Map<UnlockGroup, int> _kademe = {};

  /// What has been bought, for the store to write down.
  Iterable<String> get opened => _open;

  bool has(String id) => _open.contains(id);

  void open(String id) {
    if (_open.add(id)) _say(id);
  }

  void _say(String id) {
    final unlock = _byId[id];
    // The day-one markers are not rungs, and a restored save arrives in
    // whatever order it was written.
    if (unlock == null || unlock.kademe <= kademe(unlock.grup)) return;
    _kademe[unlock.grup] = unlock.kademe;
  }

  /// How far up [grup] the counter has been bought, 0 for nothing.
  int kademe(UnlockGroup grup) => _kademe[grup] ?? 0;

  bool grupAcik(UnlockGroup grup) => grup.gerek == null || has(grup.gerek!);

  /// A rung is for sale once the one under it is open. Nothing is hidden any
  /// more — the shop draws the whole ladder — so this only answers what
  /// money is allowed to reach next.
  bool available(Unlock unlock) {
    if (!grupAcik(unlock.grup)) return false;
    if (!unlock.grup.sirasiz) {
      return kademe(unlock.grup) == unlock.kademe - 1;
    }
    if (!unlock.grup.hatli) return true;
    final ilk = kademeler(unlock.grup).first;
    return unlock.id == ilk.id || has(ilk.id);
  }

  Iterable<Unlock> get forSale =>
      catalogue.where((u) => !has(u.id) && available(u));

  // --- What the counter asks ---

  /// Four is the cap: a fifth skewer needs a fifth dial on a grill that is
  /// already four small slots at the edge of the scene.
  int get mangalSlots => 2 + kademe(UnlockGroup.mangal);

  /// Two, then three. A fourth needed a fourth order card and patience meter
  /// in the same stretch of counter.
  int get musteriSlots => 2 + kademe(UnlockGroup.musteri);

  /// One shelf for both lines, one to three deep.
  int get bekleme => 1 + kademe(UnlockGroup.bekleme);

  int get bardakGozu => 1 + kademe(UnlockGroup.bardak);

  int get komurKademesi => kademe(UnlockGroup.komur);

  int get kasaKademesi => kademe(UnlockGroup.kasa);

  int get ikramKademesi => kademe(UnlockGroup.ikram);

  int get cirakKademesi => kademe(UnlockGroup.cirak);

  int get tabelaKademesi => kademe(UnlockGroup.tabela);

  int get kasapKademesi => kademe(UnlockGroup.kasap);

  /// How many handfuls one ingredient takes now.
  ///
  /// The knife is the only upgrade that shortens a gesture the player makes
  /// a hundred times a run, which is why it is the one the shop is built
  /// around.
  int get tutamAdedi => Balance.tutam(kademe(UnlockGroup.bicak));

  /// Each jug climbs on its own: a counter that pours ayran and no şalgam
  /// should not be paying for both. Cola is bottled and has no jug.
  int surahiKademesi(Drink icecek) => switch (icecek) {
    Drink.ayran => kademe(UnlockGroup.ayranSurahisi),
    Drink.salgam => kademe(UnlockGroup.salgamSurahisi),
    Drink.kola => 0,
  };

  bool get porsiyonHatti => has('porsiyon_hatti');

  bool get icecekHatti => has('icecek_hatti');

  Set<Ingredient> get malzemeler =>
      Ingredient.values.where((m) => has('malzeme_${m.id}')).toSet();

  Set<PlateItem> get bilesenler => porsiyonHatti
      ? PlateItem.values.where((b) => has('bilesen_${b.id}')).toSet()
      : const {};

  Set<Dessert> get tatlilar =>
      Dessert.values.where((t) => has('tatli_${t.id}')).toSet();

  Set<Drink> get icecekler => icecekHatti
      ? Drink.values.where((i) => has('icecek_${i.id}')).toSet()
      : const {};

  /// Whether the counter carries [region] yet.
  ///
  /// A locked area is not on the counter at all — it arrives with the
  /// purchase that opens it. Dimming them instead turned day one into a
  /// counter of padlocks with a shop behind it.
  bool shows(String region) {
    for (final malzeme in Ingredient.values) {
      if (region == malzeme.region) return malzemeler.contains(malzeme);
    }
    for (final bilesen in PlateItem.values) {
      if (region == bilesen.region) return bilesenler.contains(bilesen);
    }
    for (final tatli in Dessert.values) {
      if (region == tatli.region) return tatlilar.contains(tatli);
    }
    for (final icecek in Drink.values) {
      if (region == icecek.sourceRegion) return icecekler.contains(icecek);
    }
    return switch (region) {
      'tabak_kaynak' || 'tabak_hazirlama' => porsiyonHatti,
      'bardak_kaynak' || 'bardak_bekletme' => icecekHatti,
      'musteri_slot_3' => musteriSlots >= 3,
      _ => true,
    };
  }
}
