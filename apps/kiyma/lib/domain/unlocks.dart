import 'package:kiyma/domain/model/items.dart';

/// One buyable lock: what it opens and what it costs.
class Unlock {
  const Unlock(this.id, this.price);

  final String id;
  final int price;
}

/// What the shop has open, and what money opens next.
class Unlocks {
  Unlocks() : _open = {..._startOpen};

  /// Design doc 10.1. Day one is one line, two ingredients, two customers —
  /// a training day that needs no tutorial.
  static const _startOpen = {
    'mangal_2',
    'musteri_2',
    'malzeme_domates',
    'malzeme_sogan',
    'bekleme_1',
  };

  /// Design doc 10.3. Order matters: this is the list the upgrade screen
  /// shows, top to bottom.
  ///
  /// The ladder compounds: each rung of the same kind costs roughly twice the
  /// last. The whole shop is about 7,300 and ten days of play earns about
  /// 5,700, so by the end of the table the player has had to choose what not
  /// to buy — which is the point of a shop.
  static const catalogue = [
    Unlock('malzeme_biber', 100),
    Unlock('malzeme_tursu', 200),
    Unlock('bekleme_2', 250),
    Unlock('mangal_3', 450),
    Unlock('icecek_hatti', 450),
    Unlock('bekleme_3', 600),
    Unlock('porsiyon_hatti', 600),
    Unlock('musteri_3', 900),
    Unlock('mangal_4', 1050),
    Unlock('icecek_salgam', 150),
    Unlock('icecek_ayran', 250),
    Unlock('icecek_kola', 400),
    Unlock('bilesen_icli_kofte', 200),
    Unlock('bilesen_pilav', 300),
    Unlock('bilesen_patates', 450),
    Unlock('bilesen_ezme', 700),
    Unlock('tatli_baklava', 300),
  ];

  final Set<String> _open;

  bool has(String id) => _open.contains(id);

  void open(String id) => _open.add(id);

  /// A lock is offered once whatever it extends is already open — the fourth
  /// grill slot is not for sale before the third.
  bool available(Unlock unlock) => switch (unlock.id) {
    'mangal_4' => has('mangal_3'),
    'bekleme_3' => has('bekleme_2'),
    final id when id.startsWith('bilesen_') => has('porsiyon_hatti'),
    final id when id.startsWith('icecek_') => has('icecek_hatti'),
    _ => true,
  };

  Iterable<Unlock> get forSale =>
      catalogue.where((u) => !has(u.id) && available(u));

  // --- What the counter asks ---

  int get mangalSlots =>
      2 + (has('mangal_3') ? 1 : 0) + (has('mangal_4') ? 1 : 0);

  /// Two, then three. A fourth needed a fourth order card and patience meter
  /// in the same stretch of counter.
  int get musteriSlots => has('musteri_3') ? 3 : 2;

  static const _shelfLocks = ['bekleme_2', 'bekleme_3'];

  /// One shelf for both lines, one to three deep.
  int get bekleme => _shelfLocks.where(has).length + 1;

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
