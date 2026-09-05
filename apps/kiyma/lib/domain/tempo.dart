import 'dart:math' as math;

/// How the counter is reading, 0 to 100.
enum TempoHali { soguk, normal, isiniyor, ates }

/// The run's momentum: it drains on its own and is pushed back up by serving
/// people. What it is worth is a multiplier on the whole counter.
///
/// This is the reputation system of design doc 9 done properly. That one was
/// removed because it was persistent, invisible and worth a 13% swing; this
/// one lives and dies with a single run, is named on the HUD, and is worth
/// half the takings.
class Tempo {
  /// Halfway. A run opens neither hot nor cold.
  static const baslangic = 50.0;

  /// What each thing is worth. Graded: a burnt skewer costs money and a slot,
  /// losing somebody costs a whole seat for the length of their patience, and
  /// a mis-drop costs nothing anybody can see.
  static const servis = 14.0;

  /// Extra for handing it over while they are still calm — up to this much.
  static const hizliServis = 6.0;
  static const kalem = 5.0;
  static const toplama = 3.0;

  static const yanik = -12.0;
  static const kizgin = -16.0;
  static const supuruldu = -6.0;
  static const reddedildi = -6.0;

  /// How many invalid moves in a row are free.
  ///
  /// A leaning counter under a moving finger produces mis-drops that are not
  /// mistakes, and the red flash already answers those. The third in a row is
  /// no longer a slip, and it costs more each time after it.
  static const bagislanan = 2;
  static const hataBirim = -2.0;
  static const hataTaban = -8.0;

  /// The top of the meter is the hardest part to earn: a gain is worth this
  /// much less the higher tempo already is.
  ///
  /// Without it the meter pins. A counter at full supply is served every few
  /// seconds and any positive net rate parks it at 100 for the whole run,
  /// which is not a meter, it is a constant. With it the simulated player
  /// settles in the seventies and Ateş has to be worked for.
  static const doygunluk = 108.0;

  /// Drains this fast doing nothing, and faster the longer since anybody was
  /// served — that is what losing the flow is.
  static const sizma = 1.1;
  static const bosluk = 8.0;
  static const boslukArtisi = 0.12;
  static const enHizliSizma = 3.5;

  double _deger = baslangic;
  double _sonServis = 0;
  int _ustuste = 0;

  /// The last change and how long it has left on screen. The number moving is
  /// the whole of the teaching.
  double sonDegisim = 0;
  double degisimKalan = 0;

  double get deger => _deger;

  TempoHali get hal => switch (_deger) {
    < 25 => TempoHali.soguk,
    < 55 => TempoHali.normal,
    < 80 => TempoHali.isiniyor,
    _ => TempoHali.ates,
  };

  /// `0..1` across the whole meter, for drawing it.
  double get oran => _deger / 100;

  // --- What it is worth ---

  /// The takings, halved at nothing and half again at full.
  double get paraCarpani => 0.5 + _deger / 100;

  /// Above halfway the cooked window widens; below it, it does not narrow.
  ///
  /// Deliberately one-sided, and the same for patience. A meter that makes
  /// meat burn faster *and* is pushed down by burnt meat is a spiral: one bad
  /// stretch compounds into a run that cannot be recovered, only sat out. The
  /// punishment for a cold counter is that it pays half.
  double get pismeCarpani => 1 + math.max(0, _deger - 50) / 50 * 0.35;

  double get sabirCarpani =>
      _deger < 50 ? 0.9 + _deger / 50 * 0.1 : 1 + (_deger - 50) / 50 * 0.25;

  // --- What moves it ---

  /// [bekleyen] is whether anybody is actually standing at the counter.
  ///
  /// Nothing drains while nobody is waiting. Tempo is how well the rush is
  /// being handled, and an empty counter is not a rush: without this, a
  /// player on day one — where arrivals are deliberately slow — was cooling
  /// to half takings for a gap the game chose, not one they caused.
  void tick(double dt, {required bool bekleyen}) {
    if (degisimKalan > 0) degisimKalan -= dt;
    if (!bekleyen) return;
    _sonServis += dt;
    final idle = math.max(0, _sonServis - bosluk);
    final rate = math.min(enHizliSizma, sizma + idle * boslukArtisi);
    _uygula(-rate * dt, quiet: true);
  }

  void servisEdildi({required bool tamami, required double sabirOrani}) {
    _sonServis = 0;
    _ustuste = 0;
    _uygula(tamami ? servis + hizliServis * sabirOrani.clamp(0, 1) : kalem);
  }

  void altinAlindi() {
    _ustuste = 0;
    _uygula(toplama);
  }

  void basarili() => _ustuste = 0;

  /// The third mis-move in a row and every one after it, worth more each
  /// time. The first two are free.
  void gecersizHareket() {
    _ustuste++;
    if (_ustuste <= bagislanan) return;
    _uygula(math.max(hataTaban, hataBirim * (_ustuste - bagislanan)));
  }

  void etYandi() => _uygula(yanik);

  void musteriKizdi() => _uygula(kizgin);

  void altinSupuruldu() => _uygula(supuruldu);

  void urunReddedildi() => _uygula(reddedildi);

  void _uygula(double delta, {bool quiet = false}) {
    final before = _deger;
    final scaled = delta > 0 ? delta * (1 - _deger / doygunluk) : delta;
    _deger = (_deger + scaled).clamp(0, 100);
    if (quiet || (_deger - before).abs() < 0.01) return;
    sonDegisim = _deger - before;
    degisimKalan = 1.1;
  }
}
