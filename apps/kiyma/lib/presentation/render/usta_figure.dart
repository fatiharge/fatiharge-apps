/// The usta: the man behind the grill, and the voice that teaches.
///
/// He is built from the same vocabulary as the customers — flattened paths,
/// two-pass ink, arms as one tapered curve — but he is a specific person, not
/// a fourteenth silhouette. His shape is his own, his palette is fixed, and
/// his numbers are lifted off the reference drawing rather than invented:
/// with the skull's half-width as 1.00, his ears sit at 1.11, his eyes at
/// 0.41 apart and 0.24 across, and that moustache spans 1.48 — half again as
/// wide as his own head, which is the whole reason anyone recognises him.
///
/// Unlike a customer he is drawn 1:1 in scene coordinates. A customer's rig
/// lives in a 102-wide seat and is scaled up; scaling the usta the same way
/// would have thickened his outline with him, and a 2.7× stroke reads as a
/// sticker rather than as ink.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/presentation/render/figure.dart';

/// Where he stands and how big he is, chosen against the real frame rather
/// than guessed: head 142 px — 2.73× a customer's — centred at x 172 with the
/// figure's top at y 147. The grill hides everything below y ≈ 360, so 87 %
/// of him survives and all of it is head, shoulders and chest.
const ustaMerkez = 172.0;
const ustaTepe = 147.0;

/// Skull half-width. Every other measure is a ratio of this.
const _r = 71.0;

const _kafaY = 222.0;
const _kafaBoy = 59.0;
const _cene = 0.86;
const _yanak = 1.11;
const _omuzY = 321.0;
const _omuzYari = 71.0;
const _altYari = 78.0;
const _gozAralik = 29.0;
const _gozR = 17.0;
const _burun = 16.0;
const _burunY = -8.0;
const _kasKalin = 9.0;
const _kasBoy = 15.0;

/// Ink in screen pixels. Lighter in proportion than a customer's, because he
/// is nearly three times the size: the reference keeps its outline at about
/// 1.7 % of the figure's width, and matching that is what stops him looking
/// like a sticker pressed onto the room.
const _siluet = 4.6;
const _orta = 3.4;
const _ince = 2.0;

/// His colours, fixed. Customers roll a palette from a seed because they are
/// nobody in particular; he is somebody.
abstract final class UstaPalet {
  static const ten = Color(0xFFD79A63);
  static const tenGolge = Color(0xFFBE8149);
  static const yanak = Color(0xFFD9705A);
  static const sac = Color(0xFF241C19);
  static const gomlek = Color(0xFFF4EDDF);
  static const gomlekG = Color(0xFFDCD2C0);
  static const gomlekK = Color(0xFFC4B9A5);
  static const onluk = Color(0xFFFBF6EC);
  static const onlukG = Color(0xFFE4DACA);
  static const havlu = Color(0xFFF2E7DA);
  static const havluCizgi = Color(0xFFD1543F);
  static const sis = Color(0xFFB9BEC4);
  static const et = Color(0xFFB9713C);
  static const etKoyu = Color(0xFF8A4B24);

  static Color rol(String ad) => switch (ad) {
    'ten' => ten,
    'tenGolge' => tenGolge,
    'yanak' => yanak,
    'sac' => sac,
    'gomlek' => gomlek,
    'gomlekG' => gomlekG,
    'gomlekK' => gomlekK,
    'onluk' => onluk,
    'onlukG' => onlukG,
    'havlu' => havlu,
    'havluCizgi' => havluCizgi,
    'sis' => sis,
    'et' => et,
    'etKoyu' => etKoyu,
    _ => const Color(0xFFFFFFFF),
  };
}

// --- the parts only he has -------------------------------------------------

/// The tuft that survives on top.
///
/// A single ring that doubled back along the hairline was tried first and
/// filled solid: the path crosses itself, and a non-zero fill has every right
/// to read that as one blob. Three plain shapes cannot go wrong, and they are
/// what the reference actually has — the crown is bare from a tenth of the
/// way down.
List<Offset> _sacTutam(double cy) => yol(
  Offset(cx - _r * .34, cy - _kafaBoy * .90),
  [
    [
      Offset(cx - _r * .30, cy - _kafaBoy * 1.20),
      Offset(cx + _r * .12, cy - _kafaBoy * 1.28),
      Offset(cx + _r * .34, cy - _kafaBoy * 1.06),
    ],
    [
      Offset(cx + _r * .18, cy - _kafaBoy * 1.02),
      Offset(cx - _r * .10, cy - _kafaBoy * .96),
      Offset(cx - _r * .34, cy - _kafaBoy * .90),
    ],
  ],
);

/// The mass at the side and back, from the temple down behind the ear.
List<Offset> _sacYan(double cy, double s) {
  const yx = _r * _yanak;
  return yol(Offset(cx + s * yx * .62, cy - _kafaBoy * .72), [
    [
      Offset(cx + s * yx * .94, cy - _kafaBoy * .70),
      Offset(cx + s * yx * 1.05, cy - _kafaBoy * .26),
      Offset(cx + s * yx * 1.00, cy + _kafaBoy * .34),
    ],
    [
      Offset(cx + s * yx * .97, cy + _kafaBoy * .56),
      Offset(cx + s * yx * .86, cy + _kafaBoy * .58),
      Offset(cx + s * yx * .80, cy + _kafaBoy * .42),
    ],
    [
      Offset(cx + s * yx * .86, cy - _kafaBoy * .16),
      Offset(cx + s * yx * .80, cy - _kafaBoy * .56),
      Offset(cx + s * yx * .62, cy - _kafaBoy * .72),
    ],
  ]);
}

/// One lobe of his moustache — the thing you recognise him by, so it gets
/// its own shape rather than the customers' handlebar scaled up. Theirs is a
/// thin sweep; his is a thick mass that swells in the middle and hooks
/// upward at the tip, and borrowing theirs gave him two flat wings.
List<Offset> _biyik(double y, double s) {
  const gen = _r * 1.30;
  const kal = _r * .38;
  return yol(Offset(cx + s * 8, y - kal * .18), [
    [
      Offset(cx + s * gen * .34, y + 3),
      Offset(cx + s * gen * .72, y + 5),
      Offset(cx + s * gen * .95, y - kal * .04),
    ],
    [
      Offset(cx + s * gen * 1.06, y - kal * .40),
      Offset(cx + s * gen * 1.00, y - kal * .56),
      Offset(cx + s * gen * .86, y - kal * .26),
    ],
    [
      Offset(cx + s * gen * .82, y + kal * .22),
      Offset(cx + s * gen * .78, y + kal * .44),
      Offset(cx + s * gen * .60, y + kal * .86),
    ],
    [
      Offset(cx + s * gen * .38, y + kal * 1.10),
      Offset(cx + s * gen * .16, y + kal * 1.02),
      Offset(cx + s * 9, y + kal * .58),
    ],
    [
      Offset(cx + s * 8.5, y + kal * .26),
      Offset(cx + s * 8, y + kal * .02),
      Offset(cx + s * 8, y - kal * .18),
    ],
  ]);
}

/// Chin to shoulders, in the shadow the head casts on it.
List<Offset> _boyun(double cy, double oy) {
  final ust = cy + _kafaBoy * .96;
  return [
    Offset(cx - 20, ust),
    ...bez(
      Offset(cx - 20, ust),
      Offset(cx - 21, ust + (oy - ust) * .5),
      Offset(cx - 28, oy - 12),
      Offset(cx - 30, oy + 2),
    ),
    Offset(cx + 30, oy + 2),
    ...bez(
      Offset(cx + 30, oy + 2),
      Offset(cx + 28, oy - 12),
      Offset(cx + 21, ust + (oy - ust) * .5),
      Offset(cx + 20, ust),
    ),
  ];
}

/// The apron: a panel from the waist down, wider than the shirt it covers.
List<Offset> _onluk(double oy) {
  final ust = oy + 52;
  return [
    ...yol(Offset(cx - _altYari * .86, ust), [
      [
        Offset(cx - _altYari * .92, ust + 26),
        Offset(cx - _altYari * 1.02, ust + 60),
        Offset(cx - _altYari * 1.04, ust + 104),
      ],
    ]),
    Offset(cx + _altYari * 1.04, ust + 104),
    ...bez(
      Offset(cx + _altYari * 1.04, ust + 104),
      Offset(cx + _altYari * 1.02, ust + 60),
      Offset(cx + _altYari * .92, ust + 26),
      Offset(cx + _altYari * .86, ust),
    ),
  ];
}

/// The towel over one shoulder — the one prop that says kebab shop without a
/// word. `yon` is the shoulder it hangs on.
List<Offset> _havlu(double oy, double yon) {
  final ox = cx + yon * _omuzYari * .58;
  return yol(Offset(ox - yon * 15, oy - 18), [
    [
      Offset(ox + yon * 6, oy - 22),
      Offset(ox + yon * 20, oy - 14),
      Offset(ox + yon * 22, oy + 6),
    ],
    [
      Offset(ox + yon * 24, oy + 34),
      Offset(ox + yon * 20, oy + 62),
      Offset(ox + yon * 16, oy + 84),
    ],
    [
      Offset(ox + yon * 4, oy + 82),
      Offset(ox - yon * 4, oy + 80),
      Offset(ox - yon * 10, oy + 76),
    ],
    [
      Offset(ox - yon * 8, oy + 50),
      Offset(ox - yon * 12, oy + 20),
      Offset(ox - yon * 15, oy - 18),
    ],
  ]);
}

/// One stripe of the towel's check, laid across it.
List<Offset> _havluCizgi(double oy, double yon, double t) {
  final ox = cx + yon * _omuzYari * .58;
  final y = oy - 6 + t * 74;
  return [
    Offset(ox - yon * 13, y),
    Offset(ox + yon * 23, y - 4),
    Offset(ox + yon * 23, y + 4),
    Offset(ox - yon * 13, y + 8),
  ];
}

/// A skewer with the meat on it, held point-up.
({List<Sekil> parca, double boy}) _sis(Offset el, double aci) {
  const boy = 168.0;
  final u = Offset(math.sin(aci), -math.cos(aci));
  final n = Offset(-u.dy, u.dx);
  final uc = el + u * boy;
  final cubuk = <Offset>[
    el + n * 3.2 - u * 16,
    uc + n * 1.4,
    uc - n * 1.4,
    el - n * 3.2 - u * 16,
  ];
  // The mince sits along the middle of the shaft, not at its tip.
  final a = el + u * 34;
  final b = el + u * 132;
  final et = serit([a, Offset.lerp(a, b, .5)!, b], 15, 11);
  return (
    parca: [
      sekil(cubuk, 'sis', _ince),
      sekil(et, 'et', _orta),
      sekil(hilal(et, a0: -80, a1: 100), 'etKoyu', 0),
    ],
    boy: boy,
  );
}

/// His shirt, from the shoulders down past where the grill cuts him off.
List<Offset> _govde(double oy) {
  const alt = 470.0;
  final sag = yol(Offset(cx + 20, oy - 16), [
    [
      Offset(cx + _omuzYari * .56, oy - 14),
      Offset(cx + _omuzYari - 3, oy + 4),
      Offset(cx + _omuzYari + 1, oy + 36),
    ],
    [
      Offset(cx + _omuzYari + 5, oy + 66),
      const Offset(cx + _altYari - 3, alt - 60),
      const Offset(cx + _altYari, alt),
    ],
  ]);
  return [...ayna(sag).reversed, ...sag];
}

/// The still parts, built once.
class UstaParcalari {
  UstaParcalari._() {
    const cy = _kafaY;
    const oy = _omuzY;

    // --- body ---------------------------------------------------------
    final g = _govde(oy);
    govde
      ..add(sekil(g, 'gomlek', _siluet))
      ..add(sekil(hilal(g, a0: -18, a1: 128, kalinlik: .24), 'gomlekG', 0));
    for (final s in const [-1.0, 1.0]) {
      govde.add(sekil(yakaSekli(oy, 22, s), 'gomlekK', _ince));
    }
    final o = _onluk(oy);
    govde
      ..add(sekil(o, 'onluk', _orta))
      ..add(sekil(hilal(o, a1: 120), 'onlukG', 0));
    // The towel hangs on the shoulder away from the skewer, or it would be
    // draped over the arm doing the work.
    final h = _havlu(oy, -1);
    govde.add(sekil(h, 'havlu', _orta));
    for (var i = 0; i < 4; i++) {
      govde.add(sekil(_havluCizgi(oy, -1, i / 3.4 + .08), 'havluCizgi', 0));
    }

    // The neck belongs to the body group so the collar covers its foot.
    govde.insert(2, sekil(_boyun(cy, oy), 'tenGolge', _orta));

    // --- head ---------------------------------------------------------
    const kx = _r * _yanak - 1;
    final kf = kafaSekli(cy, _r, _kafaBoy, _cene, _yanak);
    kafa
      ..add(sekil(kf, 'ten', _siluet))
      ..add(sekil(hilal(kf, a0: -24, a1: 126, kalinlik: .20), 'tenGolge', 0));
    final ki = kulakIciSekli(cx + kx + 2, cy + 7);
    kafa
      ..add(sekil(ayna(ki), 'tenGolge', _ince))
      ..add(sekil(ki, 'tenGolge', _ince))
      // Ears in front of the hair: behind it they vanished entirely, and a
      // head with no ears reads as a helmet.
      ..add(sekil(_sacYan(cy, -1), 'sac', _orta))
      ..add(sekil(_sacYan(cy, 1), 'sac', _orta))
      ..add(sekil(elips(cx - kx, cy + 6, 14, 18), 'ten', _orta))
      ..add(sekil(elips(cx + kx, cy + 6, 14, 18), 'ten', _orta))
      ..add(sekil(_sacTutam(cy), 'sac', _orta))
      // Cheeks are his, not a mood: the reference has them and they are half
      // of why he reads as cheerful standing still.
      ..add(sekil(elips(cx - _gozAralik * 1.62, cy + 8, 15, 10), 'yanak', 0))
      ..add(sekil(elips(cx + _gozAralik * 1.62, cy + 8, 15, 10), 'yanak', 0))
      ..add(
        sekil(elips(cx, cy + _burunY, _burun, _burun * .82), 'tenGolge', _orta),
      );
    for (final s in const [-1.0, 1.0]) {
      kafa.add(
        sekil(_biyik(cy + 20, s), 'sac', _orta),
      );
    }
  }

  static final UstaParcalari tek = UstaParcalari._();

  final List<Sekil> govde = [];
  final List<Sekil> kafa = [];
}

/// One frame of him. Only breathing for now — the repertoire comes next, and
/// the channels are already the ones it will drive.
class UstaPoz {
  UstaPoz(double t) {
    final nefes = math.sin(t * 1.55);
    dy = nefes * 1.9;
    egim = math.sin(t * .62) * .9;
    hx = math.sin(t * .48 + 1.2) * 2.2;
    hy = nefes * 1.1;
    agiz = 7;
    final kirp = (math.sin(t * 1.07) + 1) / 2;
    if (kirp > .987) goz = .1;
  }

  double dy = 0;
  double egim = 0;
  double hx = 0;
  double hy = 0;
  double goz = 1;
  double agiz = 7;
  double kas = 0;

  /// Where each hand is, in his own space. The right one holds the skewer up
  /// over the coals — the one piece of business the grill does not hide.
  Offset get sagEl => Offset(cx + 78, _omuzY + 10 + dy * .6);
  Offset get solEl => Offset(cx - 60, _omuzY + 66 + dy * .4);
}

/// Draws the usta into scene coordinates.
///
/// Three groups, each with its own two passes, exactly as the customers are
/// drawn: body, then the bare arms, then the head. The arms carry their own
/// ink over the shirt or they read as lumps rather than limbs — the same trap
/// the customer rig fell into.
void ustaCiz(Canvas canvas, {required double t}) {
  final p = UstaPoz(t);
  final parca = UstaParcalari.tek;

  final ink = Paint()
    ..color = const Color(0xFF2E2A26)
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final inkDolgu = Paint()..color = const Color(0xFF2E2A26);

  void grup(List<Sekil> g) {
    for (final s in g) {
      if (s.kalem == 0) continue;
      canvas
        ..drawPath(s.yol, inkDolgu)
        ..drawPath(s.yol, ink..strokeWidth = s.kalem * 2);
    }
    for (final s in g) {
      canvas.drawPath(s.yol, Paint()..color = UstaPalet.rol(s.rol));
    }
  }

  canvas
    ..save()
    // Built around the seat centre the rest of the rig uses, then carried to
    // where he actually stands. One translate instead of a different origin
    // in every shape.
    ..translate(ustaMerkez - cx, p.dy)
    ..translate(cx, _omuzY)
    ..rotate(p.egim * math.pi / 180)
    ..translate(-cx, -_omuzY);

  const kolBoyu = 118.0;
  final yenler = <Sekil>[];
  final tenler = <Sekil>[];
  final sisler = <Sekil>[];
  for (final yon in const [-1.0, 1.0]) {
    final omuz = Offset(cx + yon * (_omuzYari + 1), _omuzY + 14);
    final hedef = yon < 0 ? p.solEl : p.sagEl;
    final kol = kolEgrisi(omuz, hedef, yon, kolBoyu);
    final kes = math.max(3, (kol.orta.length * .48).round());
    final ic = Offset(cx + yon * (_omuzYari - 16), _omuzY + 14);
    yenler.add(
      sekil(serit([ic, ...kol.orta.take(kes)], 21, 18), 'gomlek', _orta),
    );
    tenler
      ..add(sekil(serit(kol.orta.sublist(kes - 1), 17, 12), 'ten', _orta))
      ..add(sekil(elips(kol.el.dx, kol.el.dy, 16, 15), 'ten', _orta));
    // He holds it up over the coals: the one piece of business the grill
    // does not hide, and the reason he reads as working at all.
    if (yon > 0) sisler.addAll(_sis(kol.el, 0.22).parca);
  }

  grup([...parca.govde.take(2), ...yenler, ...parca.govde.skip(2)]);
  grup(tenler);
  grup(sisler);
  grup(parca.kafa);
  _yuz(canvas, p);
  canvas.restore();
}

/// The face, redrawn every frame because it is what carries him.
void _yuz(Canvas canvas, UstaPoz p) {
  const cy = _kafaY;
  final ux = cx + p.hx;
  final uy = cy + p.hy;
  final acik = math.max<double>(0, p.goz);
  final kasEgim = (-p.agiz * .34 + p.kas).clamp(-9.0, 9.0);

  final kalem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  for (final yon in const [-1.0, 1.0]) {
    final bx = ux + yon * _gozAralik;
    final by = uy - 16 - _gozR - _kasBoy * .9;
    canvas.drawPath(
      Path()
        ..moveTo(bx - yon * _gozR * 1.25, by + _kasBoy * .4 + kasEgim * yon)
        ..cubicTo(
          bx - yon * _gozR * .45,
          by - _kasBoy * .7,
          bx + yon * _gozR * .45,
          by - _kasBoy * .7,
          bx + yon * _gozR * 1.25,
          by + _kasBoy * .4 - kasEgim * yon,
        ),
      kalem
        ..color = UstaPalet.sac
        ..strokeWidth = _kasKalin,
    );
  }

  for (final yon in const [-1.0, 1.0]) {
    final ex = ux + yon * _gozAralik;
    final ey = uy - 16;
    final ry = 3 + (_gozR - 2) * math.min(acik, 1.35);
    final goz = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(ex, ey),
          width: _gozR * 2,
          height: ry * 2,
        ),
      );
    canvas
      ..drawPath(goz, Paint()..color = const Color(0xFFFFFDF8))
      ..drawPath(
        goz,
        kalem
          ..color = const Color(0xFF2E2A26)
          ..strokeWidth = _ince,
      );
    if (acik > .22) {
      canvas.drawCircle(
        Offset(ex + yon * _gozR * .16, ey + _gozR * .22),
        _gozR * .46,
        Paint()..color = const Color(0xFF2E2A26),
      );
    }
  }

  // The mouth sits below the moustache rather than under it: his is a
  // handlebar with a gap, and an open smile there is most of the character.
  final agiz = Rect.fromCenter(
    center: Offset(ux, uy + 41),
    width: 34,
    height: 12 + p.agiz * 1.6,
  );
  canvas
    ..drawOval(agiz, Paint()..color = const Color(0xFF3A241E))
    ..drawOval(
      agiz,
      kalem
        ..color = const Color(0xFF2E2A26)
        ..strokeWidth = _ince,
    )
    ..drawOval(
      Rect.fromCenter(
        center: Offset(ux, uy + 35),
        width: 22,
        height: math.max(3, p.agiz * .5),
      ),
      Paint()..color = const Color(0xFFF6EFE6),
    );
}
