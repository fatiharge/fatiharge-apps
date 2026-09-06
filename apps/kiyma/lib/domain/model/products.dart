import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';

/// Where meat is in its cooking, from the player's side.
///
/// `cig` and `pisiyor` behave identically — neither can be picked up. They are
/// two states only so the player can see progress; six seconds of one
/// unchanging picture reads as a hang.
enum Pisme { cig, pisiyor, pismis, yanmis }

/// One skewer position on the grill.
class MangalSlot {
  MangalSlot({this.unlocked = true});

  final bool unlocked;

  Pisme? durum;
  double _gecen = 0;

  bool get bos => durum == null;
  bool get alinabilir => durum == Pisme.pismis;
  bool get yanmis => durum == Pisme.yanmis;

  /// `0..1` over raw *and* cooking together.
  ///
  /// The two states are the same wait from the player's side, and a meter
  /// that empties and starts again between them reads as a fault.
  double get pismeOrani =>
      (_gecen / (Balance.rawSeconds + Balance.cookingSeconds)).clamp(0, 1);

  /// How wide the cooked window is right now: the day narrows it, a hot
  /// counter widens it back out.
  double pencere(int day, double carpan) => Balance.cookedWindow(day) * carpan;

  /// `0..1` through the current state, for the progress the player reads.
  double ilerleme(int day, [double carpan = 1]) => switch (durum) {
    Pisme.cig => _gecen / Balance.rawSeconds,
    Pisme.pisiyor => (_gecen - Balance.rawSeconds) / Balance.cookingSeconds,
    Pisme.pismis =>
      (_gecen - Balance.rawSeconds - Balance.cookingSeconds) /
          pencere(day, carpan),
    _ => 1,
  };

  void koy() {
    durum = Pisme.cig;
    _gecen = 0;
  }

  void bosalt() {
    durum = null;
    _gecen = 0;
  }

  /// Advances the clock. Returns `true` on the frame the meat burns, which is
  /// where the money penalty is charged.
  bool tick(double dt, int day, [double carpan = 1]) {
    if (durum == null || durum == Pisme.yanmis) return false;
    _gecen += dt;
    const cooked = Balance.rawSeconds + Balance.cookingSeconds;
    final next = switch (_gecen) {
      < Balance.rawSeconds => Pisme.cig,
      _ when _gecen < cooked => Pisme.pisiyor,
      _ when _gecen < cooked + pencere(day, carpan) => Pisme.pismis,
      _ => Pisme.yanmis,
    };
    final burned = next == Pisme.yanmis && durum != Pisme.yanmis;
    durum = next;
    return burned;
  }
}

/// Gold on the ledge, waiting to be picked up.
///
/// Left alone it is swept into the till after [Balance.sweptAfter] seconds,
/// minus the part that goes missing — the point of touching it is the tip,
/// not the sale.
class Altin {
  Altin(this.miktar, {this.tip = 0}) : kalan = Balance.sweptAfter;

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
class Durum {
  Durum({this.gerekenTutam = Balance.tutamAdedi});

  /// How many handfuls make one whole ingredient on *this* wrap.
  ///
  /// Carried by the product rather than read off [Balance] because it is
  /// bought: a sharper knife takes three handfuls down to one, and a wrap
  /// already on the counter when the shop closed keeps the rule it was
  /// started under.
  final int gerekenTutam;

  bool etli = false;
  final Map<Malzeme, int> _tutamlar = {};

  bool sarili = false;
  bool kagitli = false;

  /// How much of [malzeme] is on, `0..`[Balance.tutamAdedi].
  int tutam(Malzeme malzeme) => _tutamlar[malzeme] ?? 0;

  /// Only the finished ones. A third of an onion is not an onion: it does
  /// not satisfy an order, it does not earn the bonus, and the customer
  /// who asked for no onion is not offended by it.
  Set<Malzeme> get malzemeler => {
    for (final entry in _tutamlar.entries)
      if (entry.value >= gerekenTutam) entry.key,
  };

  void malzemeEkle(Malzeme malzeme) => _tutamlar[malzeme] = tutam(malzeme) + 1;

  /// Ingredients go on any time before the roll, meat or no meat.
  ///
  /// Requiring the meat first made the grill block the whole wrap line: with
  /// nothing to do but wait for a skewer, the six seconds of cooking were six
  /// seconds of standing still.
  bool malzemeKabul(Malzeme malzeme) =>
      !sarili && tutam(malzeme) < gerekenTutam;

  bool get sarilabilir => etli && !sarili;
  bool get kagitBekliyor => sarili && !kagitli;
  bool get hazir => kagitli;
}

/// A plate being built, then carried.
class Porsiyon {
  Porsiyon({this.gerekenTutam = Balance.tutamAdedi});

  /// See [Durum.gerekenTutam].
  final int gerekenTutam;

  bool lavasli = false;
  bool etli = false;
  final Map<Bilesen, int> _tutamlar = {};

  int tutam(Bilesen bilesen) => _tutamlar[bilesen] ?? 0;

  Set<Bilesen> get bilesenler => {
    for (final entry in _tutamlar.entries)
      if (entry.value >= gerekenTutam) entry.key,
  };

  void bilesenEkle(Bilesen bilesen) => _tutamlar[bilesen] = tutam(bilesen) + 1;

  /// Flatbread first and mandatory; nothing else lands on a bare plate.
  bool get lavasBekliyor => !lavasli;

  /// After the bread, in any order — the same rule as the wrap, and for the
  /// same reason: waiting on the grill is not a decision.
  bool bilesenKabul(Bilesen bilesen) =>
      lavasli && tutam(bilesen) < gerekenTutam;

  /// No rolling and no paper: a plate is servable as soon as it has meat on
  /// bread. Components are the optional part.
  bool get hazir => lavasli && etli;
}

/// A glass on the shelf. Locked while it fills, so it cannot be carried away
/// half full.
class Bardak {
  Icecek? icerik;
  double _dolum = 0;

  bool get bos => icerik == null && _dolum == 0;
  bool get doluyor => _dolum > 0;
  bool get hazir => icerik != null && _dolum == 0;

  /// How full it is, `0..1`. What the glass is drawn at while it pours.
  double get dolumOrani => doluyor ? 1 - _dolum / Balance.pourSeconds : 1;

  /// What is in it, or on its way in.
  Icecek? get icecek => icerik ?? _bekleyen;

  Icecek? _bekleyen;

  void doldur(Icecek icecek) {
    _bekleyen = icecek;
    _dolum = Balance.pourSeconds;
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
sealed class Urun {
  const Urun();

  /// The shelf it goes back to when a customer refuses it. One shelf for both
  /// lines: two half-depth ones drew everything at half size.
  String? get beklemeBolgesi;

  /// Where it is drawn at its natural size, so carrying it never shrinks it.
  String get evi;
}

class DurumUrun extends Urun {
  const DurumUrun(this.durum);

  final Durum durum;

  @override
  String get beklemeBolgesi => 'bekleme_alani';

  @override
  String get evi => 'durum_hazirlama';
}

class PorsiyonUrun extends Urun {
  const PorsiyonUrun(this.porsiyon);

  final Porsiyon porsiyon;

  @override
  String get beklemeBolgesi => 'bekleme_alani';

  @override
  String get evi => 'tabak_hazirlama';
}

class TatliUrun extends Urun {
  const TatliUrun(this.tatli);

  final Tatli tatli;

  @override
  String? get beklemeBolgesi => null;

  @override
  String get evi => tatli.region;
}

class IcecekUrun extends Urun {
  const IcecekUrun(this.icecek);

  final Icecek icecek;

  @override
  String? get beklemeBolgesi => icecek.poured ? 'bardak_bekletme' : null;

  @override
  String get evi => icecek.poured ? 'bardak_bekletme' : icecek.sourceRegion;
}
