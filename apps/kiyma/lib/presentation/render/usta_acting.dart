/// What the usta is doing, as opposed to what he looks like.
///
/// The rig in `usta_figure.dart` draws one frame from a pose. This is what
/// decides the pose: a small state machine with one beat running at a time,
/// a clock on it, and a rule about what may interrupt what.
///
/// Two things shape everything here.
///
/// The first is that **nothing he does may change the game.** He is scenery
/// with opinions. He turns a skewer that was going to cook anyway, he looks
/// at the purse the coins were flying to anyway. The rules never see him.
///
/// The second is that **most of him is behind cloth.** The apron is drawn
/// over the arms, so a hand anywhere inside `cx ± 78` below y 333 is invisible
/// no matter how well it is animated, and the grill's rim cuts him at y ≈ 430.
/// Every gesture below either comes up over the chest or reaches out past the
/// apron's edge. A hand that does neither is work nobody sees.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/animation.dart' show Curves;
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/presentation/render/figure.dart' show cx;
import 'package:kiyma/presentation/render/usta_figure.dart';

/// One thing he is in the middle of.
///
/// The first five are chores — his own business, picked at random when the
/// counter leaves him alone. The rest are reactions, and a reaction always
/// wins: a man who finishes twirling his moustache before noticing a customer
/// walked out is not a character, he is a loop.
enum UstaIsi {
  bekle,
  sisCevir,
  biyikBur,
  alinSil,
  etrafaBak,
  esne,
  sevin,
  kiz,
  keseyeBak,
  fikir,
  konus,
}

/// How long each one runs, in seconds.
const _sure = <UstaIsi, double>{
  UstaIsi.bekle: 0,
  UstaIsi.sisCevir: 2.2,
  UstaIsi.biyikBur: 1.9,
  UstaIsi.alinSil: 1.5,
  UstaIsi.etrafaBak: 1.7,
  UstaIsi.esne: 2.0,
  UstaIsi.sevin: 1.15,
  UstaIsi.kiz: 1.35,
  UstaIsi.keseyeBak: 1.0,
  UstaIsi.fikir: 1.8,
  UstaIsi.konus: 0,
};

/// Chores, and how often each is picked. The grill is his job, so it comes up
/// twice as often as anything else.
const _isler = <UstaIsi>[
  UstaIsi.sisCevir,
  UstaIsi.sisCevir,
  UstaIsi.biyikBur,
  UstaIsi.alinSil,
  UstaIsi.etrafaBak,
];

/// What he does when there is genuinely nothing on: the same list with a yawn
/// in it. A yawn mid-rush does not read as bored, it reads as contempt.
const _bosIsler = <UstaIsi>[..._isler, UstaIsi.esne, UstaIsi.etrafaBak];

/// Which reaction an event earns, if any.
///
/// The frequencies are measured, not guessed: `kabul` fires 114 times in a
/// busy day-30 run and `musteriMemnun` 62, so neither can move him or he
/// twitches all shift. What is left is rare enough to be worth a face.
const _tepkiler = <DayEvent, UstaIsi>{
  DayEvent.musteriKizgin: UstaIsi.kiz,
  DayEvent.reddedildi: UstaIsi.kiz,
  DayEvent.yandi: UstaIsi.kiz,
  DayEvent.altinSupuruldu: UstaIsi.kiz,
  DayEvent.mangalDolu: UstaIsi.kiz,
  DayEvent.bahsis: UstaIsi.keseyeBak,
  DayEvent.seri: UstaIsi.sevin,
  DayEvent.gunlukHedef: UstaIsi.sevin,
  DayEvent.sonSiparis: UstaIsi.etrafaBak,
  DayEvent.fikirDegisti: UstaIsi.fikir,
};

/// A reaction cannot be cut short by another of the same weight, or a busy
/// second turns him into a strobe. Anger outranks delight — the news the
/// player has to act on is always the bad news.
const _agirlik = <UstaIsi, int>{
  UstaIsi.kiz: 3,
  UstaIsi.sevin: 2,
  UstaIsi.fikir: 2,
  UstaIsi.keseyeBak: 1,
  UstaIsi.konus: 2,
};

/// Directs him: holds the current beat, ages it, and hands out a pose.
class UstaYonetmeni {
  UstaYonetmeni({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;

  UstaIsi _is = UstaIsi.bekle;
  double _gecen = 0;
  double _boyu = 0;

  /// Until the next chore. Seeded long so he stands still for a moment when a
  /// day opens rather than starting mid-gesture.
  double _sonraki = 3.5;

  /// The talking beat has no length of its own — it runs while there is a
  /// lesson on screen and stops when there is not.
  bool _konusuyor = false;

  /// A tiny idle clock of its own, so his mouth does not fall into step with
  /// the breathing.
  double _saat = 0;

  UstaIsi get isi => _is;

  /// Where the lesson is pointing, in scene coordinates, or null.
  ///
  /// He cannot reach it — his arm is 106 px and the counter is a room wide —
  /// so this is a direction, not a destination: the hand goes as far that way
  /// as the arm goes and the head turns after it. Pointing at a thing you
  /// cannot touch is what pointing is.
  Offset? isaret;

  /// The lesson is speaking, so he should be.
  void konusma({required bool acik}) {
    if (acik == _konusuyor) return;
    _konusuyor = acik;
    if (acik) {
      _basla(UstaIsi.konus);
    } else if (_is == UstaIsi.konus) {
      _bitir();
    }
  }

  /// Something happened. Whether he notices is this table's business.
  void olay(DayEvent kind) {
    final tepki = _tepkiler[kind];
    if (tepki == null) return;
    // Talking outranks everything but anger: a man who breaks off a lesson to
    // admire his own purse is not teaching.
    if ((_agirlik[tepki] ?? 0) < (_agirlik[_is] ?? 0)) return;
    _basla(tepki);
  }

  void _basla(UstaIsi is_) {
    _is = is_;
    _gecen = 0;
    _boyu = _sure[is_] ?? 1;
    // Nothing else starts while a reaction is playing, and a beat of quiet
    // after it — chores stepping straight on the end of a reaction is what
    // made him look like he was being operated rather than living.
    _sonraki = _boyu + 1.6 + _random.nextDouble() * 3.5;
  }

  void _bitir() {
    _is = UstaIsi.bekle;
    _gecen = 0;
    _boyu = 0;
  }

  /// [bosTezgah] is "nobody waiting and nothing cooking", which is the only
  /// state a yawn belongs in.
  void tick(double dt, {bool bosTezgah = false}) {
    _saat += dt;
    if (_is != UstaIsi.bekle && _is != UstaIsi.konus) {
      _gecen += dt;
      if (_gecen >= _boyu) _bitir();
    }
    if (_is != UstaIsi.bekle) return;
    _sonraki -= dt;
    if (_sonraki > 0) return;
    final havuz = bosTezgah ? _bosIsler : _isler;
    _basla(havuz[_random.nextInt(havuz.length)]);
  }

  /// The pose for this frame.
  UstaPoz poz(double t) {
    final p = UstaPoz.durgun(t);
    _isaretEt(p, t);
    final u = _boyu <= 0 ? 0.0 : (_gecen / _boyu).clamp(0.0, 1.0);
    switch (_is) {
      case UstaIsi.bekle:
        _bosluk(p, t);
      case UstaIsi.sisCevir:
        _sisCevir(p, u);
      case UstaIsi.biyikBur:
        _biyikBur(p, u);
      case UstaIsi.alinSil:
        _alinSil(p, u);
      case UstaIsi.etrafaBak:
        _etrafaBak(p, u);
      case UstaIsi.esne:
        _esne(p, u);
      case UstaIsi.sevin:
        _sevin(p, u);
      case UstaIsi.kiz:
        _kiz(p, u);
      case UstaIsi.keseyeBak:
        _keseyeBak(p, u);
      case UstaIsi.fikir:
        _fikir(p, u);
      case UstaIsi.konus:
        _konus(p, _saat);
    }
    return p;
  }

  /// The pointing hand, laid under whatever else he is doing.
  ///
  /// Under, not instead of: a lesson runs for a minute and a man who holds
  /// one arm out for a minute without blinking is a signpost. He still
  /// breathes, still talks, still reacts — the arm is simply out.
  void _isaretEt(UstaPoz p, double t) {
    final hedef = isaret;
    if (hedef == null) return;
    // From the shoulder on the side the target is, so he never points across
    // his own chest.
    final sag = hedef.dx > ustaMerkez;
    final omuz = ustaOmuz(sag ? 1 : -1);
    // In scene coordinates the figure stands at `ustaMerkez`; the rig works
    // in its own space, so the direction has to be carried across.
    final yon = Offset(hedef.dx - ustaMerkez + cx, hedef.dy) - omuz;
    final uzunluk = yon.distance;
    if (uzunluk < 1) return;
    // Flattened, never steeper than about twenty degrees below horizontal.
    // Half these targets are on the counter below him, and an arm pointed
    // down at one goes behind the apron and then under the grill's rim — a
    // gesture the player cannot see is a gesture that did not happen. Out to
    // the side says "over there" just as well and stays in the picture.
    var birim = yon / uzunluk;
    if (birim.dy > .34) birim = Offset(birim.dx, .34);
    // And pushed outward, away from his own middle. Half these targets are
    // almost underneath him — the grill is — and the honest direction from
    // either shoulder to something under his chest points *across* his body,
    // which puts the hand behind the apron. Out to the side and down is what
    // a man pointing at his own feet actually does with his arm, and it is
    // the only version of it anyone can see.
    final disa = sag ? 1.0 : -1.0;
    if (birim.dx * disa < .52) birim = Offset(disa * .52, birim.dy);
    birim = birim / birim.distance;
    // A little life in it, so the arm is held rather than pinned.
    final salinim = 1 + math.sin(t * 1.9) * .035;
    final el = omuz + birim * ustaKolBoyu * .94 * salinim;
    if (sag) {
      p.sagHedef = el;
    } else {
      p.solHedef = el;
    }
    p
      ..hx += (sag ? 4.5 : -4.5)
      ..bakisX += sag ? 6 : -6
      ..bakisY += 1.5;
  }

  /// Standing there. Not nothing: the eyes drift, because a gaze nailed to
  /// one spot is the single loudest tell that a face is a drawing.
  void _bosluk(UstaPoz p, double t) {
    p
      ..bakisX = math.sin(t * .37) * 2.6
      ..bakisY = math.sin(t * .29 + 2.1) * 1.4;
  }

  /// Reaching down and out to turn a skewer. Out past the apron's edge on
  /// purpose — inside it the hand is behind cloth and the whole beat is a
  /// shoulder twitch.
  void _sisCevir(UstaPoz p, double u) {
    final a = _yay(u);
    p
      ..sagHedef = Offset.lerp(p.sagEl, const Offset(cx + 100, 406), a)
      ..egim += 2.4 * a
      ..hx += 7 * a
      ..hy += 4 * a
      ..bakisX = 5 * a
      ..bakisY = 5.5 * a
      ..goz = math.min(p.goz, 1 - .35 * a)
      ..agiz = 7 - 4 * a
      ..agizEn = 1 - .12 * a;
  }

  /// The moustache. It is the reason anyone recognises him, so of course he
  /// plays with it. The hand goes to the tip, outside the skull and under the
  /// hair, which is where fingers on a moustache actually are.
  void _biyikBur(UstaPoz p, double u) {
    final a = _yay(u);
    final bur = math.sin(u * math.pi * 4) * a;
    p
      ..solHedef = Offset.lerp(
        p.solEl,
        Offset(cx - 110, 244 + bur * 3),
        a,
      )
      ..hx -= 2.5 * a
      ..egim -= 1.2 * a
      ..bakisX = -2 * a
      ..agiz = 7 - 6 * a
      ..gulus = 3.5 * a
      ..kas = .35 * a;
  }

  /// Wiping his face, with the hand the towel hangs by. His own forehead is
  /// out of reach — the arm is 106 and the brow is 160 away — so the wipe
  /// meets in the middle: the hand comes up to the moustache and the head
  /// comes down into it, which is what a wipe looks like anyway.
  void _alinSil(UstaPoz p, double u) {
    final a = _yay(u);
    final sil = math.sin(u * math.pi * 3) * a;
    p
      ..solHedef = Offset.lerp(p.solEl, Offset(cx - 56 + sil * 18, 256), a)
      ..hy += 9 * a
      ..hx -= 2 * a
      ..goz = math.min(p.goz, 1 - .8 * a)
      ..agiz = 7 - 5 * a
      ..kas = .25 * a;
  }

  /// A look around the shop. No hands: it is a head and a pair of eyes, and
  /// it is the cheapest beat in the set for how much it sells him as awake.
  void _etrafaBak(UstaPoz p, double u) {
    final tara = math.sin(u * math.pi * 2);
    final a = _yay(u);
    p
      ..hx += tara * 6
      ..egim += tara * 1.6
      ..bakisX = tara * 7.5
      ..bakisY = -1.5 * a
      ..kas = .45 * a
      ..agiz = 7 - 3 * a;
  }

  /// Only when the shop is dead, and that is checked outside: a yawning usta
  /// mid-rush reads as contempt.
  void _esne(UstaPoz p, double u) {
    final a = _yay(u);
    p
      ..agiz = 7 + 26 * a
      ..agizEn = 1 - .22 * a
      ..goz = math.min(p.goz, 1 - .95 * a)
      ..hy += 5 * a
      ..hx -= 3 * a
      ..kas = .5 * a;
  }

  /// Delight. A hop, a fist up beside the head — beside it, so it clears both
  /// the apron and his own face — and the grin that goes with them.
  void _sevin(UstaPoz p, double u) {
    final a = _yay(u);
    final zipla = math.max<double>(0, math.sin(u * math.pi * 2));
    p
      ..dy -= 9 * zipla
      ..sagHedef = Offset.lerp(p.sagEl, const Offset(cx + 96, 232), a)
      // Wide and shallow. Tall and narrow is a shout, and at the first pass
      // that is exactly what his delight looked like.
      ..agiz = 7 + 9 * a
      ..agizEn = 1 + .46 * a
      ..gulus = 11 * a
      ..kas = .9 * a
      ..goz = math.min(p.goz, 1 - .55 * a)
      ..bakisY = -3 * a;
  }

  /// Anger. Brows in, mouth open and narrow, head forward, and a shudder that
  /// dies rather than a shake that repeats — he is annoyed, not malfunctioning.
  void _kiz(UstaPoz p, double u) {
    final a = _yay(u);
    final titre = math.sin(u * math.pi * 9) * (1 - u) * (1 - u);
    p
      ..ofke = math.min(1, a * 1.5)
      ..agiz = 7 + 17 * a
      ..agizEn = 1 - .26 * a
      ..gulus = -4 * a
      ..hx += titre * 4.5
      ..hy += 4 * a
      ..egim += titre * 2.2
      ..goz = math.min(p.goz, 1 - .18 * a)
      ..bakisY = 2.5 * a;
  }

  /// The coins are going to his purse, which is up and to the right of him.
  /// He follows them and is pleased about it.
  void _keseyeBak(UstaPoz p, double u) {
    final a = _yay(u);
    p
      ..hx += 9 * a
      ..egim += 2.2 * a
      ..bakisX = 8 * a
      ..bakisY = -4.5 * a
      ..kas = .55 * a
      ..gulus = 5 * a
      ..agiz = 7 - 2 * a
      ..agizEn = 1 + .12 * a;
  }

  /// Something occurred to him: a finger up, brows up, and the bulb.
  void _fikir(UstaPoz p, double u) {
    final a = _yay(u);
    final gir = Curves.easeOutBack.transform(math.min(1, u * 3));
    p
      ..fikir = a
      ..solHedef = Offset.lerp(p.solEl, const Offset(cx - 94, 236), gir)
      ..kas = .85 * a
      ..goz = math.min(p.goz, 1 + .2 * a)
      ..agiz = 7 + 6 * a
      ..agizEn = 1 - .30 * a
      ..bakisY = -3.5 * a
      ..hy -= 3 * a;
  }

  /// Talking, for as long as the lesson lasts.
  ///
  /// Two frequencies rather than one: a mouth on a single sine is a fish, and
  /// the second beat is what makes it read as syllables. It never closes all
  /// the way, because a mouth that shuts between every syllable chews.
  void _konus(UstaPoz p, double t) {
    final hece =
        .5 + .5 * math.sin(t * 11.5) * .7 + .3 * math.sin(t * 4.3 + 1.1);
    p
      ..agiz = 3 + 13 * hece.clamp(0.0, 1.0)
      ..agizEn = 1 + .08 * hece
      ..gulus = 2
      ..kas = .2 + .25 * math.sin(t * 1.9)
      ..hx += math.sin(t * 2.3) * 2.2;
  }

  /// Up and back down: one gesture, not a state that snaps on and off.
  static double _yay(double u) => math.sin(u * math.pi);
}
