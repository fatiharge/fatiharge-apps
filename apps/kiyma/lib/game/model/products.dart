import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/model/items.dart';

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

  /// `0..1` through the current state, for the progress the player reads.
  double ilerleme(int day) => switch (durum) {
    Pisme.cig => _gecen / Balance.rawSeconds,
    Pisme.pisiyor => (_gecen - Balance.rawSeconds) / Balance.cookingSeconds,
    Pisme.pismis =>
      (_gecen - Balance.rawSeconds - Balance.cookingSeconds) /
          Balance.cookedWindow(day),
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
  bool tick(double dt, int day) {
    if (durum == null || durum == Pisme.yanmis) return false;
    _gecen += dt;
    const cooked = Balance.rawSeconds + Balance.cookingSeconds;
    final next = switch (_gecen) {
      < Balance.rawSeconds => Pisme.cig,
      _ when _gecen < cooked => Pisme.pisiyor,
      _ when _gecen < cooked + Balance.cookedWindow(day) => Pisme.pismis,
      _ => Pisme.yanmis,
    };
    final burned = next == Pisme.yanmis && durum != Pisme.yanmis;
    durum = next;
    return burned;
  }
}

/// A wrap being built, then carried.
class Durum {
  bool etli = false;
  final Set<Malzeme> malzemeler = {};
  bool sarili = false;
  bool kagitli = false;

  /// Ingredients go on after the meat and before the roll — the two rules
  /// that keep the layer stack meaningful.
  bool malzemeKabul(Malzeme malzeme) =>
      etli && !sarili && !malzemeler.contains(malzeme);

  bool get sarilabilir => etli && !sarili;
  bool get kagitBekliyor => sarili && !kagitli;
  bool get hazir => kagitli;
}

/// A plate being built, then carried.
class Porsiyon {
  bool lavasli = false;
  bool etli = false;
  final Set<Bilesen> bilesenler = {};

  /// Flatbread first and mandatory; nothing else lands on a bare plate.
  bool get lavasBekliyor => !lavasli;
  bool bilesenKabul(Bilesen bilesen) => etli && !bilesenler.contains(bilesen);

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
  double get dolumOrani => doluyor ? 1 - _dolum / Balance.pourSeconds : 1;

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

  /// Which shelf it goes back to when a customer refuses it.
  String? get beklemeBolgesi;
}

class DurumUrun extends Urun {
  const DurumUrun(this.durum);

  final Durum durum;

  @override
  String get beklemeBolgesi => 'durum_bekleme';
}

class PorsiyonUrun extends Urun {
  const PorsiyonUrun(this.porsiyon);

  final Porsiyon porsiyon;

  @override
  String get beklemeBolgesi => 'tabak_birakma';
}

class TatliUrun extends Urun {
  const TatliUrun(this.tatli);

  final Tatli tatli;

  @override
  String? get beklemeBolgesi => null;
}

class IcecekUrun extends Urun {
  const IcecekUrun(this.icecek);

  final Icecek icecek;

  @override
  String? get beklemeBolgesi => icecek.poured ? 'bardak_bekletme' : null;
}
