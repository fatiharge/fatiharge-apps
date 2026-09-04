/// The two product lines a customer can order.
enum UrunTipi { durum, porsiyon }

/// Wrap ingredients. Deliberately a separate set from [Bilesen]: one set goes
/// in the bread, the other on the plate, and the rule is teachable because it
/// never has an exception.
enum Malzeme {
  domates('domates'),
  sogan('sogan'),
  biber('biber'),
  tursu('tursu'),
  // The design doc's section 3.2 said rocket; the art was drawn as parsley,
  // which is what an Adana wrap actually carries. The doc follows the art.
  maydanoz('maydanoz');

  const Malzeme(this.id);

  /// Matches the region suffix, the composition layer name and the asset
  /// prefix all at once — the art pipeline named them together.
  final String id;

  String get region => 'malzeme_$id';
  String get trayAsset => '${id}_tepsi';
  String get stripAsset => '${id}_durum';
  String get portionAsset => '${id}_porsiyon';
}

/// Plate components.
enum Bilesen {
  icliKofte('icli_kofte', 'icli_kofte'),
  pilav('pilav', 'bulgur_pilavi'),
  patates('patates', 'patates'),
  patlican('patlican', 'patlican'),
  ezme('ezme', 'ezme');

  const Bilesen(this.id, this.assetBase);

  final String id;

  /// Bulgur pilaf is the one place where the region name and the asset name
  /// disagree — `malzeme_pilav` holds `bulgur_pilavi_tepsi`.
  final String assetBase;

  String get region => 'malzeme_$id';
  String get trayAsset => '${assetBase}_tepsi';
  String get portionAsset => '${assetBase}_porsiyon';
}

/// One dessert. The line's whole job is to be the quick, certain sale that
/// lets the player breathe (design doc 6); three of them was three locks and
/// three prices for one idea.
enum Tatli {
  baklava('baklava');

  const Tatli(this.id);

  final String id;

  String get region => 'tatli_$id';
  String get asset => id;
}

enum Icecek {
  salgam('salgam'),
  ayran('ayran'),

  /// Served from the bottle: no glass, no pouring.
  kola('kola');

  const Icecek(this.id);

  final String id;

  bool get poured => this != Icecek.kola;

  /// The jug this is poured from, or the crate the bottle comes out of.
  String get sourceRegion => poured ? 'surahi_$id' : 'kola_kaynak';

  String get sourceAsset => poured ? 'surahi_$id' : 'kola_sise_grup';

  /// The full glass, or the single bottle.
  String get servedAsset => poured ? id : 'kola_sise';
}
