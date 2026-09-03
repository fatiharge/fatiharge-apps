import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/products.dart';

/// What the hand is holding mid-drag.
///
/// Only one of these exists at a time: the interaction vocabulary is a tap, a
/// drag and an upward flick, and nothing in it moves two things at once.
sealed class Carried {
  const Carried();

  /// The region the drag started in, so a refused or dropped item can go back.
  String get origin;

  /// The asset drawn under the finger.
  String get asset;
}

class CigKiyma extends Carried {
  const CigKiyma();

  @override
  String get origin => 'malzeme_kiyma';

  @override
  String get asset => 'sis_cig';
}

/// Meat lifted off a grill slot. [yanik] meat is carried too — the bin is the
/// only place it can go, and until it gets there it blocks the slot.
class PismisEt extends Carried {
  const PismisEt(this.slot, {this.yanik = false});

  final int slot;
  final bool yanik;

  @override
  String get origin => 'mangal_alani';

  @override
  String get asset => yanik ? 'sis_yanmis' : 'adana_pismis';
}

class Lavas extends Carried {
  const Lavas();

  @override
  String get origin => 'lavas_kaynak';

  @override
  String get asset => 'lavas_tek';
}

class Kagit extends Carried {
  const Kagit();

  @override
  String get origin => 'kagit_kaynak';

  @override
  String get asset => 'kagit_alani';
}

class MalzemeTutami extends Carried {
  const MalzemeTutami(this.malzeme);

  final Malzeme malzeme;

  @override
  String get origin => malzeme.region;

  @override
  String get asset => malzeme.portionAsset;
}

class BilesenTutami extends Carried {
  const BilesenTutami(this.bilesen);

  final Bilesen bilesen;

  @override
  String get origin => bilesen.region;

  @override
  String get asset => bilesen.portionAsset;
}

/// A jug on its way to a glass. It is the jug that moves, not the glass.
class Surahi extends Carried {
  const Surahi(this.icecek);

  final Icecek icecek;

  @override
  String get origin => icecek.sourceRegion;

  @override
  String get asset => icecek.sourceAsset;
}

/// A finished thing being taken somewhere: a customer, a shelf, or the bin.
class HazirUrun extends Carried {
  const HazirUrun(this.urun, this.origin, {this.slot, this.fromSource = false});

  final Urun urun;

  /// Set when it came out of a numbered slot, so a refusal can put it back
  /// where it was.
  final int? slot;

  /// True for desserts and bottles, which are taken from an endless source:
  /// dropping one nowhere costs nothing and puts nothing back.
  final bool fromSource;

  @override
  final String origin;

  @override
  String get asset => switch (urun) {
    DurumUrun() => 'doner_bekleme',
    PorsiyonUrun() => 'porsiyon_hazirlama',
    TatliUrun(:final tatli) => tatli.asset,
    IcecekUrun(:final icecek) => icecek.servedAsset,
  };
}
