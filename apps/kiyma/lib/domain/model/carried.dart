import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/products.dart';

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

  /// The region that draws this at its natural size. Picking something up
  /// should never shrink it, and where the drag started is not the answer —
  /// a wrap lifted off the shelf is still a wrap.
  String get evi;
}

class RawMince extends Carried {
  const RawMince();

  @override
  String get origin => 'malzeme_kiyma';

  @override
  String get asset => 'sis_cig';

  @override
  String get evi => 'mangal_alani';
}

/// Meat lifted off a grill slot. [yanik] meat is carried too — the bin is the
/// only place it can go, and until it gets there it blocks the slot.
class CookedMeat extends Carried {
  const CookedMeat(this.slot, {this.yanik = false});

  final int slot;
  final bool yanik;

  @override
  String get origin => 'mangal_alani';

  @override
  String get asset => yanik ? 'sis_yanmis' : 'adana_pismis';

  @override
  String get evi => 'mangal_alani';
}

class Flatbread extends Carried {
  const Flatbread();

  @override
  String get origin => 'lavas_kaynak';

  @override
  String get asset => 'lavas_tek';

  @override
  String get evi => 'durum_hazirlama';
}

/// Greaseproof paper, applied to a rolled wrap on the shelf.
class Paper extends Carried {
  const Paper();

  @override
  String get origin => 'kagit_kaynak';

  @override
  String get asset => 'kagit_alani';

  @override
  String get evi => 'kagit_kaynak';
}

class IngredientHandful extends Carried {
  const IngredientHandful(this.malzeme);

  final Ingredient malzeme;

  @override
  String get origin => malzeme.region;

  @override
  String get evi => malzeme.region;

  @override
  String get asset => malzeme.portionAsset;
}

class PlateItemHandful extends Carried {
  const PlateItemHandful(this.bilesen);

  final PlateItem bilesen;

  @override
  String get origin => bilesen.region;

  @override
  String get evi => bilesen.region;

  @override
  String get asset => bilesen.portionAsset;
}

/// A jug on its way to a glass. It is the jug that moves, not the glass.
class Jug extends Carried {
  const Jug(this.icecek);

  final Drink icecek;

  @override
  String get origin => icecek.sourceRegion;

  @override
  String get evi => icecek.sourceRegion;

  @override
  String get asset => icecek.sourceAsset;
}

/// A finished thing being taken somewhere: a customer, a shelf, or the bin.
class FinishedProduct extends Carried {
  const FinishedProduct(
    this.urun,
    this.origin, {
    this.slot,
    this.fromSource = false,
  });

  final Product urun;

  /// Set when it came out of a numbered slot, so a refusal can put it back
  /// where it was.
  final int? slot;

  /// True for desserts and bottles, which are taken from an endless source:
  /// dropping one nowhere costs nothing and puts nothing back.
  final bool fromSource;

  @override
  final String origin;

  @override
  String get evi => urun.evi;

  @override
  String get asset => switch (urun) {
    WrapProduct() => 'doner_bekleme',
    PlateProduct() => 'porsiyon_hazirlama',
    DessertProduct(:final tatli) => tatli.asset,
    DrinkProduct(:final icecek) => icecek.servedAsset,
  };
}
