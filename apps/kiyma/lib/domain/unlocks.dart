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
enum Grup {
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
  porsiyon('porsiyon', sirasiz: true),
  tatli('tatli', sirasiz: true),
  icecek('icecek', sirasiz: true),
  bardak('bardak', gerek: 'icecek_hatti'),
  ayranSurahisi('ayran_surahisi', gerek: 'icecek_ayran'),
  salgamSurahisi('salgam_surahisi', gerek: 'icecek_salgam');

  const Grup(this.id, {this.gerek, this.sirasiz = false});

  /// Names `grup.<id>` in the translations, and nothing else.
  final String id;

  /// A lock nothing in the group sells before. Only the drink shelves need
  /// one: a faster ayran jug means nothing on a counter with no ayran.
  final String? gerek;

  /// Separate goods rather than tiers of one thing. Pickles are not a better
  /// pepper, so the shop offers them all at once and lets the prices decide
  /// the order; the first rung still gates the rest where it is a line.
  final bool sirasiz;
}

/// One buyable rung: what it opens, what it costs, and where it sits.
class Unlock {
  const Unlock(this.id, this.price, this.grup, this.kademe);

  final String id;
  final int price;
  final Grup grup;

  /// 1-based. A rung is offered once the one under it is open.
  final int kademe;
}

/// What the shop has open, and what money opens next.
class Unlocks {
  Unlocks() : _open = {..._startOpen} {
    _open.forEach(_say);
  }

  /// Design doc 10.1. Day one is one line, two ingredients, two customers —
  /// a training day that needs no tutorial.
  static const _startOpen = {
    'mangal_2',
    'musteri_2',
    'malzeme_domates',
    'malzeme_sogan',
    'bekleme_1',
  };

  /// Design doc 10.3, rebuilt as ladders.
  ///
  /// Within a group each rung is about 2.2x the one under it — a little
  /// under a day's compounding squared, so the next rung is one or two runs
  /// away and never the same run. Across groups a rung is priced at roughly
  /// half of what the day it is meant for pays, so buying one is a decision
  /// inside a single day rather than a saving-up project.
  static const catalogue = [
    Unlock('mangal_3', 520, Grup.mangal, 1),
    Unlock('mangal_4', 1500000, Grup.mangal, 2),

    Unlock('bicak_1', 2000, Grup.bicak, 1),
    Unlock('bicak_2', 770000, Grup.bicak, 2),

    Unlock('komur_1', 54, Grup.komur, 1),
    Unlock('komur_2', 2200, Grup.komur, 2),
    Unlock('komur_3', 350000, Grup.komur, 3),
    Unlock('komur_4', 17000000, Grup.komur, 4),
    Unlock('komur_5', 830000000, Grup.komur, 5),

    Unlock('malzeme_biber', 160, Grup.malzeme, 1),
    Unlock('malzeme_tursu', 9900, Grup.malzeme, 2),

    Unlock('bekleme_2', 140, Grup.bekleme, 1),
    Unlock('bekleme_3', 210000, Grup.bekleme, 2),

    Unlock('musteri_3', 4000, Grup.musteri, 1),

    Unlock('ikram_1', 27000, Grup.ikram, 1),
    Unlock('ikram_2', 16000000, Grup.ikram, 2),
    Unlock('ikram_3', 370000000, Grup.ikram, 3),

    Unlock('kasa_1', 20000, Grup.kasa, 1),
    Unlock('kasa_2', 5300000, Grup.kasa, 2),
    Unlock('kasa_3', 420000000, Grup.kasa, 3),

    Unlock('cirak_1', 14000, Grup.cirak, 1),
    Unlock('cirak_2', 3600000, Grup.cirak, 2),
    Unlock('cirak_3', 150000000, Grup.cirak, 3),

    Unlock('tabela_1', 190000, Grup.tabela, 1),
    Unlock('tabela_2', 23000000, Grup.tabela, 2),
    Unlock('tabela_3', 290000000, Grup.tabela, 3),

    Unlock('kasap_1', 680, Grup.kasap, 1),
    Unlock('kasap_2', 1100000, Grup.kasap, 2),
    Unlock('kasap_3', 98000000, Grup.kasap, 3),

    Unlock('porsiyon_hatti', 14, Grup.porsiyon, 1),
    Unlock('bilesen_icli_kofte', 98, Grup.porsiyon, 2),
    Unlock('bilesen_pilav', 110000, Grup.porsiyon, 3),
    Unlock('bilesen_patates', 23000000, Grup.porsiyon, 4),
    Unlock('bilesen_ezme', 43000000, Grup.porsiyon, 5),

    Unlock('tatli_baklava', 2700, Grup.tatli, 1),

    Unlock('icecek_hatti', 30, Grup.icecek, 1),
    Unlock('icecek_salgam', 470, Grup.icecek, 2),
    Unlock('icecek_ayran', 130000, Grup.icecek, 3),
    Unlock('icecek_kola', 12000000, Grup.icecek, 4),

    Unlock('bardak_2', 1300, Grup.bardak, 1),
    Unlock('bardak_3', 2400000, Grup.bardak, 2),

    Unlock('surahi_ayran_1', 300000, Grup.ayranSurahisi, 1),
    Unlock('surahi_ayran_2', 110000000, Grup.ayranSurahisi, 2),
    Unlock('surahi_ayran_3', 300000000, Grup.ayranSurahisi, 3),

    Unlock('surahi_salgam_1', 19000, Grup.salgamSurahisi, 1),
    Unlock('surahi_salgam_2', 62000000, Grup.salgamSurahisi, 2),
    Unlock('surahi_salgam_3', 240000000, Grup.salgamSurahisi, 3),
  ];

  static final Map<String, Unlock> _byId = {
    for (final unlock in catalogue) unlock.id: unlock,
  };

  /// Every rung of one ladder, bought and unbought. What the shop draws.
  static List<Unlock> kademeler(Grup grup) =>
      catalogue.where((unlock) => unlock.grup == grup).toList();

  final Set<String> _open;

  /// How far up each ladder the counter has been bought.
  ///
  /// Counted as ids arrive rather than derived on demand: the coal tier and
  /// the knife's handful count are asked for on every frame, and a catalogue
  /// scan a frame is a scan too many.
  final Map<Grup, int> _kademe = {};

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
  int kademe(Grup grup) => _kademe[grup] ?? 0;

  bool grupAcik(Grup grup) => grup.gerek == null || has(grup.gerek!);

  /// A rung is for sale once the one under it is open. Nothing is hidden any
  /// more — the shop draws the whole ladder — so this only answers what
  /// money is allowed to reach next.
  bool available(Unlock unlock) {
    if (!grupAcik(unlock.grup)) return false;
    if (!unlock.grup.sirasiz) {
      return kademe(unlock.grup) == unlock.kademe - 1;
    }
    final ilk = kademeler(unlock.grup).first;
    return unlock.id == ilk.id || has(ilk.id);
  }

  Iterable<Unlock> get forSale =>
      catalogue.where((u) => !has(u.id) && available(u));

  // --- What the counter asks ---

  /// Four is the cap: a fifth skewer needs a fifth dial on a grill that is
  /// already four small slots at the edge of the scene.
  int get mangalSlots => 2 + kademe(Grup.mangal);

  /// Two, then three. A fourth needed a fourth order card and patience meter
  /// in the same stretch of counter.
  int get musteriSlots => 2 + kademe(Grup.musteri);

  /// One shelf for both lines, one to three deep.
  int get bekleme => 1 + kademe(Grup.bekleme);

  int get bardakGozu => 1 + kademe(Grup.bardak);

  int get komurKademesi => kademe(Grup.komur);

  int get kasaKademesi => kademe(Grup.kasa);

  int get ikramKademesi => kademe(Grup.ikram);

  int get cirakKademesi => kademe(Grup.cirak);

  int get tabelaKademesi => kademe(Grup.tabela);

  int get kasapKademesi => kademe(Grup.kasap);

  /// How many handfuls one ingredient takes now.
  ///
  /// The knife is the only upgrade that shortens a gesture the player makes
  /// a hundred times a run, which is why it is the one the shop is built
  /// around.
  int get tutamAdedi => Balance.tutam(kademe(Grup.bicak));

  /// Each jug climbs on its own: a counter that pours ayran and no şalgam
  /// should not be paying for both. Cola is bottled and has no jug.
  int surahiKademesi(Icecek icecek) => switch (icecek) {
    Icecek.ayran => kademe(Grup.ayranSurahisi),
    Icecek.salgam => kademe(Grup.salgamSurahisi),
    Icecek.kola => 0,
  };

  bool get porsiyonHatti => has('porsiyon_hatti');

  bool get icecekHatti => has('icecek_hatti');

  Set<Malzeme> get malzemeler =>
      Malzeme.values.where((m) => has('malzeme_${m.id}')).toSet();

  Set<Bilesen> get bilesenler => porsiyonHatti
      ? Bilesen.values.where((b) => has('bilesen_${b.id}')).toSet()
      : const {};

  Set<Tatli> get tatlilar =>
      Tatli.values.where((t) => has('tatli_${t.id}')).toSet();

  Set<Icecek> get icecekler => icecekHatti
      ? Icecek.values.where((i) => has('icecek_${i.id}')).toSet()
      : const {};

  /// Whether the counter carries [region] yet.
  ///
  /// A locked area is not on the counter at all — it arrives with the
  /// purchase that opens it. Dimming them instead turned day one into a
  /// counter of padlocks with a shop behind it.
  bool shows(String region) {
    for (final malzeme in Malzeme.values) {
      if (region == malzeme.region) return malzemeler.contains(malzeme);
    }
    for (final bilesen in Bilesen.values) {
      if (region == bilesen.region) return bilesenler.contains(bilesen);
    }
    for (final tatli in Tatli.values) {
      if (region == tatli.region) return tatlilar.contains(tatli);
    }
    for (final icecek in Icecek.values) {
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
