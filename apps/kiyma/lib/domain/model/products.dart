import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';

/// Where meat is in its cooking, from the player's side.
///
/// `cig` and `pisiyor` behave identically — neither can be picked up. They are
/// two states only so the player can see progress; six seconds of one
/// unchanging picture reads as a hang.
enum Doneness { cig, pisiyor, pismis, yanmis }

/// One skewer position on the grill.
class GrillSlot {
  GrillSlot({this.komur = 0, this.pencere = 1, this.unlocked = true});

  /// How much wider the day's rule makes the cooked window.
  final double pencere;

  /// How good the coal is. Worked into the two halves of the cook once,
  /// because both are read on every frame of every slot.
  final int komur;

  final bool unlocked;

  late final double _cig = Balance.rawSeconds * Balance.komurCarpani(komur);
  late final double _pisme =
      Balance.cookingSeconds * Balance.komurCarpani(komur);

  Doneness? durum;
  double _gecen = 0;

  bool get bos => durum == null;
  bool get alinabilir => durum == Doneness.pismis;
  bool get yanmis => durum == Doneness.yanmis;

  /// `0..1` over raw *and* cooking together.
  ///
  /// The two states are the same wait from the player's side, and a meter
  /// that empties and starts again between them reads as a fault.
  double get pismeOrani => (_gecen / (_cig + _pisme)).clamp(0, 1);

  /// How wide the cooked window is right now: the day narrows it, a hot
  /// counter widens it back out.
  double pencereGenisligi(int day, double carpan) =>
      Balance.cookedWindow(day, komur: komur) * carpan * pencere;

  /// `0..1` through the current state, for the progress the player reads.
  double ilerleme(int day, [double carpan = 1]) => switch (durum) {
    Doneness.cig => _gecen / _cig,
    Doneness.pisiyor => (_gecen - _cig) / _pisme,
    Doneness.pismis => (_gecen - _cig - _pisme) / pencereGenisligi(day, carpan),
    _ => 1,
  };

  void koy() {
    durum = Doneness.cig;
    _gecen = 0;
  }

  void bosalt() {
    durum = null;
    _gecen = 0;
  }

  /// Advances the clock. Returns `true` on the frame the meat burns, which is
  /// where the money penalty is charged.
  bool tick(double dt, int day, [double carpan = 1]) {
    if (durum == null || durum == Doneness.yanmis) return false;
    _gecen += dt;
    final cooked = _cig + _pisme;
    final next = switch (_gecen) {
      _ when _gecen < _cig => Doneness.cig,
      _ when _gecen < cooked => Doneness.pisiyor,
      _ when _gecen < cooked + pencereGenisligi(day, carpan) => Doneness.pismis,
      _ => Doneness.yanmis,
    };
    final burned = next == Doneness.yanmis && durum != Doneness.yanmis;
    durum = next;
    return burned;
  }
}

/// Gold on the ledge, waiting to be picked up.
///
/// Left alone it is swept into the till after [Balance.sweptAfter] seconds,
/// minus the part that goes missing — the point of touching it is the tip,
/// not the sale.
class CoinPile {
  CoinPile(this.miktar, {this.tip = 0, int kasa = 0})
    : kalan = Balance.supurulmeSuresi(kasa);

  /// The art each pile is drawn with. Chosen at random so a counter of four
  /// payments does not read as one repeated sprite.
  static const tipler = ['altin', 'altin_kese', 'altin_kule'];

  final int miktar;
  final int tip;
  double kalan;

  String get asset => tipler[tip % tipler.length];

  /// The last stretch, where the pile flashes and the tag turns red.
  bool get aceleli => kalan <= Balance.sweptWarning;
}

/// A wrap being built, then carried.
class Wrap {
  Wrap({this.gerekenTutam = Balance.tutamBasi});

  /// How many handfuls make one whole ingredient on *this* wrap.
  ///
  /// Carried by the product rather than read off [Balance] because it is
  /// bought: a sharper knife takes three handfuls down to one, and a wrap
  /// already on the counter when the shop closed keeps the rule it was
  /// started under.
  final int gerekenTutam;

  bool etli = false;
  final Map<Ingredient, int> _tutamlar = {};

  bool sarili = false;
  bool kagitli = false;

  /// How much of [malzeme] is on, `0..`[Balance.tutamBasi].
  int tutam(Ingredient malzeme) => _tutamlar[malzeme] ?? 0;

  /// Only the finished ones. A third of an onion is not an onion: it does
  /// not satisfy an order, it does not earn the bonus, and the customer
  /// who asked for no onion is not offended by it.
  Set<Ingredient> get malzemeler => {
    for (final entry in _tutamlar.entries)
      if (entry.value >= gerekenTutam) entry.key,
  };

  void malzemeEkle(Ingredient malzeme) =>
      _tutamlar[malzeme] = tutam(malzeme) + 1;

  /// Ingredients go on any time before the roll, meat or no meat.
  ///
  /// Requiring the meat first made the grill block the whole wrap line: with
  /// nothing to do but wait for a skewer, the six seconds of cooking were six
  /// seconds of standing still.
  bool malzemeKabul(Ingredient malzeme) =>
      !sarili && tutam(malzeme) < gerekenTutam;

  bool get sarilabilir => etli && !sarili;
  bool get kagitBekliyor => sarili && !kagitli;
  bool get hazir => kagitli;
}

/// A plate being built, then carried.
class Plate {
  Plate({this.gerekenTutam = Balance.tutamBasi});

  /// See [Wrap.gerekenTutam].
  final int gerekenTutam;

  bool lavasli = false;
  bool etli = false;
  final Map<PlateItem, int> _tutamlar = {};

  int tutam(PlateItem bilesen) => _tutamlar[bilesen] ?? 0;

  Set<PlateItem> get bilesenler => {
    for (final entry in _tutamlar.entries)
      if (entry.value >= gerekenTutam) entry.key,
  };

  void bilesenEkle(PlateItem bilesen) =>
      _tutamlar[bilesen] = tutam(bilesen) + 1;

  /// Flatbread first and mandatory; nothing else lands on a bare plate.
  bool get lavasBekliyor => !lavasli;

  /// After the bread, in any order — the same rule as the wrap, and for the
  /// same reason: waiting on the grill is not a decision.
  bool bilesenKabul(PlateItem bilesen) =>
      lavasli && tutam(bilesen) < gerekenTutam;

  /// No rolling and no paper: a plate is servable as soon as it has meat on
  /// bread. Components are the optional part.
  bool get hazir => lavasli && etli;
}

/// A glass on the shelf. Locked while it fills, so it cannot be carried away
/// half full.
class Glass {
  Drink? icerik;
  double _dolum = 0;
  double _sure = Balance.pourSeconds;

  bool get bos => icerik == null && _dolum == 0;
  bool get doluyor => _dolum > 0;
  bool get hazir => icerik != null && _dolum == 0;

  /// How full it is, `0..1`. What the glass is drawn at while it pours.
  double get dolumOrani => doluyor ? 1 - _dolum / _sure : 1;

  /// What is in it, or on its way in.
  Drink? get icecek => icerik ?? _bekleyen;

  Drink? _bekleyen;

  /// [sure] is how long this counter's jug takes, which a wider mouth
  /// shortens. Held so the meter drawn on the glass matches the wait.
  void doldur(Drink icecek, double sure) {
    _bekleyen = icecek;
    _sure = sure;
    _dolum = sure;
  }

  void tick(double dt) {
    if (!doluyor) return;
    _dolum -= dt;
    if (_dolum <= 0) {
      _dolum = 0;
      icerik = _bekleyen;
      _bekleyen = null;
    }
  }
}

/// Something finished that can be handed over, parked or binned.
sealed class Product {
  const Product();

  /// The shelf it goes back to when a customer refuses it. One shelf for both
  /// lines: two half-depth ones drew everything at half size.
  String? get beklemeBolgesi;

  /// Where it is drawn at its natural size, so carrying it never shrinks it.
  String get evi;
}

class WrapProduct extends Product {
  const WrapProduct(this.durum);

  final Wrap durum;

  @override
  String get beklemeBolgesi => 'bekleme_alani';

  @override
  String get evi => 'durum_hazirlama';
}

class PlateProduct extends Product {
  const PlateProduct(this.porsiyon);

  final Plate porsiyon;

  @override
  String get beklemeBolgesi => 'bekleme_alani';

  @override
  String get evi => 'tabak_hazirlama';
}

class DessertProduct extends Product {
  const DessertProduct(this.tatli);

  final Dessert tatli;

  @override
  String? get beklemeBolgesi => null;

  @override
  String get evi => tatli.region;
}

class DrinkProduct extends Product {
  const DrinkProduct(this.icecek);

  final Drink icecek;

  @override
  String? get beklemeBolgesi => icecek.poured ? 'bardak_bekletme' : null;

  @override
  String get evi => icecek.poured ? 'bardak_bekletme' : icecek.sourceRegion;
}
