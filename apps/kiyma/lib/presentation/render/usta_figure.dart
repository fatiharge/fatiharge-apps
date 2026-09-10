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
const ustaTepe = 122.0;

/// The anchor every other measure is a ratio of. It is no longer the skull's
/// own half-width: the skull is `_r * _yanak` = 66, narrower than the anchor,
/// because the moustache and the hair are what the reference sizes against
/// the head, and they were already the width they should be.
const _r = 71.0;

const _kafaY = 218.0;
const _kafaBoy = 80.0;
const _cene = 0.60;
const _yanak = 0.93;
const _omuzY = 321.0;
const _omuzYari = 71.0;
const _altYari = 78.0;
const _gozAralik = 29.0;
const _gozR = 18.5;
const _burun = 19.0;
const _burunY = 5.0;
const _kasKalin = 10.5;

/// How far the raised brow's spine rides above the eye's top edge. It used to
/// scale the arch; the arch is now the taper in [_kas].
const _kasBoy = 15.0;

/// Eye half-height. The reference eye is a tall almond — 1.38 high to wide —
/// and drawing it as a disc was the single largest measured gap in the face.
const _gozBoy = 25.25;
const _gozY = -8.0;
const _gozEgim = 9.0;
const _bebek = 6.8;
const _bebekBoy = 11.0;

/// The gaze. One offset for BOTH eyes, never mirrored: mirroring is what made
/// him look through the player instead of at something.
const _bakisX = -3.6;
const _bakisY = 2.4;
const _isik = 2.4;
const _kasBas = 3.5;
const _kasDis = 18.0;
const _kasIc = 13.0;
const _kasIcBas = 20.0;
const _kasUc = 1.2;

const _agizYari = 19.0;
const _agizY = 42.0;
const _agizBoy = 5.5;

/// The shirt's neckline, a pixel under the jaw. The reference has no neck:
/// the head sits on the collar and only a wedge of throat shows through the
/// opening.
const _yakaY = 299.0;
const _yakaDip = 316.0;
const _onlukY = 333.0;

const _havluX = 54.0;
const _havluYari = 15.0;
const _havluUst = 292.0;
const _havluAlt = 366.0;

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
  static const yanak = Color(0xFFD8704A);
  static const sac = Color(0xFF241C19);
  static const gomlek = Color(0xFFF4EDDF);
  static const gomlekG = Color(0xFFDCD2C0);
  static const gomlekK = Color(0xFFC4B9A5);
  static const onluk = Color(0xFFFBF6EC);
  static const onlukG = Color(0xFFE4DACA);
  static const havlu = Color(0xFFF7EFE0);
  static const havluG = Color(0xFFE7DCC9);
  static const havluCizgi = Color(0xFFD44B3B);
  static const sis = Color(0xFFB9BEC4);
  static const agizIc = Color(0xFF6E2317);
  static const dis = Color(0xFFFDF7E6);
  static const dil = Color(0xFFC4574A);
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
    'havluG' => havluG,
    'havluCizgi' => havluCizgi,
    'sis' => sis,
    'agizIc' => agizIc,
    'dis' => dis,
    'dil' => dil,
    'et' => et,
    'etKoyu' => etKoyu,
    _ => const Color(0xFFFFFFFF),
  };
}

// --- the parts only he has -------------------------------------------------

/// His skull: a rounded square, not an egg.
///
/// The shared [kafaSekli] carries its width at mid-height and rounds off hard
/// at the crown, which at his size reads as a balloon with a face drawn on
/// it. The reference is a box with the corners taken off — full width by a
/// third of the way down, near-vertical past the ears, and a jaw that turns
/// in late onto a broad flat chin. The corner radius is the whole difference,
/// so the crown's first control sits out at .70 of the half-width rather than
/// on the axis.
List<Offset> _kafaSekli(double cy) {
  final ust = cy - _kafaBoy;
  final alt = cy + _kafaBoy;
  const w = _r * _yanak;
  const ck = w * _cene;
  return yol(Offset(cx, ust), [
    [
      Offset(cx + w * .70, ust),
      Offset(cx + w, cy - _kafaBoy * .68),
      Offset(cx + w, cy - _kafaBoy * .20),
    ],
    [
      Offset(cx + w, cy + _kafaBoy * .34),
      Offset(cx + w * .94, cy + _kafaBoy * .60),
      Offset(cx + ck * 1.06, cy + _kafaBoy * .88),
    ],
    // The jaw turns onto the chin at a corner, not a tangent: the reference
    // has one, and rounding it is what made the last head an egg.
    [
      Offset(cx + ck * .96, alt + _kafaBoy * .04),
      Offset(cx - ck * .96, alt + _kafaBoy * .04),
      Offset(cx - ck * 1.06, cy + _kafaBoy * .88),
    ],
    [
      Offset(cx - w * .94, cy + _kafaBoy * .60),
      Offset(cx - w, cy + _kafaBoy * .34),
      Offset(cx - w, cy - _kafaBoy * .20),
    ],
    [
      Offset(cx - w, cy - _kafaBoy * .68),
      Offset(cx - w * .70, ust),
      Offset(cx, ust),
    ],
  ]);
}

/// What is left of his hair: a cap at the crown and a sideburn beside each
/// ear, both cut out of the skull's own outline.
///
/// Off the reference: the cap covers the top tenth of the head and everything
/// under it is bare. Cutting them from the skull is what keeps hair from
/// standing above the head or widening it — the tuft this replaces stood 14
/// px proud of the skull and the side masses bulged past its rim, and between
/// them the skull read two sizes small.
///
/// Neither carries an outline: `sac` is within a shade of the ink, so a
/// stroke buys nothing but fat on every side.
List<Offset> _sacTutam(List<Offset> kafa) =>
    hilal(kafa, a0: 238, a1: 302, kalinlik: .22);

/// One sideburn: nothing at the temple, widest beside the ear, gone by the
/// jaw. Mirrored with [ayna] rather than taking a sign — two hand-fitted
/// halves drift, and on a face this symmetrical the drift is the first thing
/// you see.
List<Offset> _sacYan(List<Offset> kafa) =>
    hilal(kafa, a0: 168, a1: 208, kalinlik: .26);

/// The fold inside the ear, at his scale rather than a customer's. Drawn
/// before the skull, so the head trims the inner half away and what is left
/// is a hook instead of a ring.
List<Offset> _kulakIci(double ex, double ey, double s) => yol(
  Offset(ex - s * 5, ey - 9),
  [
    [
      Offset(ex + s * 4, ey - 10),
      Offset(ex + s * 8, ey - 3),
      Offset(ex + s * 6, ey + 4),
    ],
    [
      Offset(ex + s * 4, ey + 9),
      Offset(ex - s * 2, ey + 10),
      Offset(ex - s * 5, ey + 7),
    ],
    [
      Offset(ex - s * 1, ey + 7),
      Offset(ex + s * 3.5, ey + 4),
      Offset(ex + s * 3.5, ey - 1),
    ],
    [
      Offset(ex + s * 3.5, ey - 5),
      Offset(ex + s * 1, ey - 8),
      Offset(ex - s * 5, ey - 9),
    ],
  ],
);

/// One lobe of his moustache — the thing you recognise him by, so it gets its
/// own shape rather than the customers' handlebar scaled up.
///
/// Three moves in order: the top edge sweeps out and sags as it goes, the
/// mass hangs past the mouth, and only past a deliberate waist does the tip
/// whip up into a hook ending level with the cheekbone. Ending that sweep
/// level is what made the old one read as a bar. `y` is the top edge where it
/// meets the nose, not a centre line: the whole mass hangs below it.
List<Offset> _biyik(double y, double s) {
  const gen = _r * 1.46;
  const kal = _r * .60;
  return yol(Offset(cx + s * 2.5, y), [
    [
      Offset(cx + s * gen * .07, y - kal * .09),
      Offset(cx + s * gen * .14, y - kal * .09),
      Offset(cx + s * gen * .22, y - kal * .06),
    ],
    [
      Offset(cx + s * gen * .34, y - kal * .01),
      Offset(cx + s * gen * .44, y + kal * .11),
      Offset(cx + s * gen * .56, y + kal * .19),
    ],
    // The waist. Without this thinning, the hook past it is just more mass.
    [
      Offset(cx + s * gen * .66, y + kal * .25),
      Offset(cx + s * gen * .72, y + kal * .27),
      Offset(cx + s * gen * .78, y + kal * .27),
    ],
    [
      Offset(cx + s * gen * .88, y + kal * .15),
      Offset(cx + s * gen * .97, y - kal * .27),
      Offset(cx + s * gen * .97, y - kal * .47),
    ],
    // The point leans back over the face and the outer flank drops behind it,
    // so the tip curls inward instead of spiking outward.
    [
      Offset(cx + s * gen * 1.02, y - kal * .33),
      Offset(cx + s * gen * 1.00, y - kal * .24),
      Offset(cx + s * gen * 1.00, y + kal * .10),
    ],
    [
      Offset(cx + s * gen * .92, y + kal * .62),
      Offset(cx + s * gen * .80, y + kal * 1.02),
      Offset(cx + s * gen * .58, y + kal * 1.06),
    ],
    [
      Offset(cx + s * gen * .40, y + kal * 1.09),
      Offset(cx + s * gen * .30, y + kal * .98),
      Offset(cx + s * gen * .22, y + kal * .80),
    ],
    // The bottom edge climbing back to the axis is the parting; the two
    // lobes' ink meeting there is the seam, so neither lobe crosses cx.
    [
      Offset(cx + s * gen * .14, y + kal * .60),
      Offset(cx + s * 7, y + kal * .44),
      Offset(cx + s * 3.5, y + kal * .34),
    ],
    [
      Offset(cx + s * 2.9, y + kal * .22),
      Offset(cx + s * 2.5, y + kal * .08),
      Offset(cx + s * 2.5, y),
    ],
  ]);
}

/// One eyebrow, as a filled taper rather than a stroked line.
///
/// The reference brow is thick at the nose and comes to a point at the
/// temple. A constant-width stroke cannot do that, and a constant width is
/// most of why the old pair read as two black bananas stuck to the hair.
///
/// [kalk] is how far the spine rides above the eye's top edge. The two sides
/// get different numbers on purpose: that difference is the expression.
List<Offset> _kas(
  double ex,
  double ey,
  double yon, {
  required double kalk,
  required double ic,
}) {
  final tepe = ey - _gozBoy - kalk;
  // The higher it rides, the further it has to dive to meet the temple.
  final dalis = kalk * .80;
  final orta = yol(Offset(ex + yon * _kasDis, tepe + dalis), [
    [
      Offset(ex + yon * _kasDis * .52, tepe + dalis * .38),
      Offset(ex + yon * _kasDis * .16, tepe),
      Offset(ex - yon * ic * .38, tepe),
    ],
    [
      Offset(ex - yon * ic * .72, tepe),
      Offset(ex - yon * ic, tepe + dalis * .22),
      Offset(ex - yon * ic, tepe + dalis * .35),
    ],
  ]);
  return serit(orta, _kasUc, _kasKalin * .5);
}

/// The nose: narrow between the eyes, swelling into a bulb whose base sits
/// down inside the moustache's parting. A pear, not an ellipse — the taper at
/// the top is the whole difference between a nose and a ball on a face.
List<Offset> _burunSekli(double x, double y) {
  const w = _burun;
  const h = _burun * .95;
  // Right half only, then mirrored. Two sides written out by hand drift
  // apart; ayna() cannot be used because the nose travels with the head sway
  // and is no longer centred on cx.
  final sag = yol(const Offset(0, -h), [
    [
      const Offset(w * .30, -h * .99),
      const Offset(w * .72, -h * .62),
      const Offset(w * .94, h * .10),
    ],
    [
      const Offset(w * 1.02, h * .44),
      const Offset(w * .96, h * .72),
      const Offset(w * .74, h * .90),
    ],
    [
      const Offset(w * .56, h * 1.02),
      const Offset(w * .30, h * 1.04),
      const Offset(0, h * 1.04),
    ],
  ]);
  return [
    for (final q in sag) Offset(x + q.dx, y + q.dy),
    for (final q in sag.reversed.skip(1)) Offset(x - q.dx, y + q.dy),
  ];
}

/// The opening of the mouth, widest low down: an open laugh, not an O.
List<Offset> _agizSekli(double x, double y, double h) {
  const w = _agizYari;
  final sag = yol(Offset(0, -h), [
    [
      Offset(w * .62, -h * 1.00),
      Offset(w * .98, -h * .56),
      Offset(w * .98, h * .14),
    ],
    [Offset(w * 1.00, h * .56), Offset(w * .70, h), Offset(0, h)],
  ]);
  return [
    for (final q in sag) Offset(x + q.dx, y + q.dy),
    for (final q in sag.reversed.skip(1)) Offset(x - q.dx, y + q.dy),
  ];
}

/// The upper teeth as one unbroken band. Drawn as separate teeth at this size
/// they collapse into a row of grey lines, and the reference does not draw
/// them either.
List<Offset> _disSekli(double x, double y, double h) {
  const w = _agizYari;
  final ust = y - h * .80;
  final alt = y - h * .26;
  return yol(Offset(x - w * .40, ust + 2.5), [
    [
      Offset(x - w * .24, ust - 1.5),
      Offset(x + w * .24, ust - 1.5),
      Offset(x + w * .40, ust + 2.5),
    ],
    [
      Offset(x + w * .56, alt - 4),
      Offset(x + w * .48, alt - .5),
      Offset(x + w * .28, alt),
    ],
    [
      Offset(x + w * .10, alt + 2),
      Offset(x - w * .10, alt + 2),
      Offset(x - w * .28, alt),
    ],
    [
      Offset(x - w * .48, alt - .5),
      Offset(x - w * .56, alt - 4),
      Offset(x - w * .40, ust + 2.5),
    ],
  ]);
}

/// The tongue on the floor of the mouth. It is the warm note in the face and
/// the reason an open mouth reads as a laugh rather than as a hole.
List<Offset> _dilSekli(double x, double y, double h) {
  const w = _agizYari;
  final ust = y + h * .26;
  final alt = y + h * .92;
  return yol(Offset(x - w * .54, ust + 2), [
    [
      Offset(x - w * .26, ust - 3),
      Offset(x + w * .26, ust - 3),
      Offset(x + w * .54, ust + 2),
    ],
    [Offset(x + w * .56, alt - 3), Offset(x + w * .30, alt), Offset(x, alt)],
    [
      Offset(x - w * .30, alt),
      Offset(x - w * .56, alt - 3),
      Offset(x - w * .54, ust + 2),
    ],
  ]);
}

/// Chin to collar. There is no neck: in the reference the jaw sits straight
/// on the shirt and the only skin below it is the wedge the collar's V lets
/// through, so that wedge is the whole shape. The column that was here was a
/// fifth of everything you can see of him.
List<Offset> _boyun() {
  const ust = _kafaY + _kafaBoy * .72;
  return [
    const Offset(cx - 17, ust),
    const Offset(cx + 17, ust),
    ...bez(
      const Offset(cx + 17, ust),
      const Offset(cx + 17, ust + 22),
      const Offset(cx + 10, _yakaDip - 11),
      const Offset(cx + 1, _yakaDip),
    ),
    ...bez(
      const Offset(cx - 1, _yakaDip),
      const Offset(cx - 10, _yakaDip - 11),
      const Offset(cx - 17, ust + 22),
      const Offset(cx - 17, ust),
    ),
  ];
}

/// One flap of the open collar, shoulder seam to the V.
///
/// The reference's collar is one stroke per side: down off the seam, up over
/// the point where it stands off the chest, down again into the V. The peak
/// is the whole tell — without it a collar is a bib, which is what two flat
/// slabs gave him.
List<Offset> _yaka(double s) => yol(
  Offset(cx + s * 30, _yakaY - 3),
  [
    [
      Offset(cx + s * 27, _yakaY + 9),
      Offset(cx + s * 23, _yakaY + 11),
      Offset(cx + s * 18, _yakaY + 4),
    ],
    [
      Offset(cx + s * 15, _yakaY + 9),
      Offset(cx + s * 13, _yakaY + 12),
      Offset(cx + s * 2, _yakaDip),
    ],
    [
      Offset(cx + s * 6, _yakaY - 6),
      Offset(cx + s * 18, _yakaY - 8),
      Offset(cx + s * 30, _yakaY - 3),
    ],
  ],
);

/// The button placket: one line in the reference, running from the V down
/// under the apron.
List<Offset> _yakaPat() => const [
  Offset(cx - 3.5, _yakaDip - 2),
  Offset(cx + 3.5, _yakaDip - 2),
  Offset(cx + 4.5, _onlukY + 10),
  Offset(cx - 4.5, _onlukY + 10),
];

/// The apron: a panel from the waist down, wider than the shirt it covers.
///
/// Its hem used to sit thirteen pixels under the grill's edge, and therefore
/// was never once seen. It has to clear 360 or it may as well not be drawn.
List<Offset> _onluk() {
  const ust = _onlukY;
  return [
    ...yol(const Offset(cx - _altYari * .80, ust), [
      [
        const Offset(cx - _altYari * .88, ust + 30),
        const Offset(cx - _altYari * .98, ust + 70),
        const Offset(cx - _altYari * 1.00, ust + 130),
      ],
    ]),
    const Offset(cx + _altYari * 1.00, ust + 130),
    ...bez(
      const Offset(cx + _altYari * 1.00, ust + 130),
      const Offset(cx + _altYari * .98, ust + 70),
      const Offset(cx + _altYari * .88, ust + 30),
      const Offset(cx + _altYari * .80, ust),
    ),
  ];
}

/// The towel over one shoulder — the one prop that says kebab shop without a
/// word. Two near-parallel edges with a slight inboard drift, not a lozenge:
/// the taper it had before read as a scarf.
List<Offset> _havlu(double yon) {
  final ox = cx + yon * _havluX;
  final dis = yon * _havluYari;
  return [
    Offset(ox + dis, _havluUst),
    ...bez(
      Offset(ox + dis, _havluUst),
      Offset(ox + dis * 1.04, _havluUst + 40),
      Offset(ox + dis * .90, _havluAlt - 40),
      Offset(ox + dis * .74, _havluAlt),
    ),
    Offset(ox - dis * 1.14, _havluAlt - 8),
    ...bez(
      Offset(ox - dis * 1.14, _havluAlt - 8),
      Offset(ox - dis * 1.08, _havluAlt - 60),
      Offset(ox - dis * 1.02, _havluUst + 44),
      Offset(ox - dis, _havluUst),
    ),
  ];
}

/// The fold where the towel doubles over the shoulder. Its own shape rather
/// than a crease inside the towel's path: a path that doubles back fills as
/// one blob, which the hair already taught us once.
List<Offset> _havluKat(double yon) {
  final ox = cx + yon * _havluX;
  final dis = yon * _havluYari;
  return [
    Offset(ox + dis * 1.22, _havluUst - 4),
    ...bez(
      Offset(ox + dis * 1.22, _havluUst - 4),
      Offset(ox + dis * 1.18, _havluUst + 16),
      Offset(ox + dis * .96, _havluUst + 30),
      Offset(ox + dis * .10, _havluUst + 33),
    ),
    ...bez(
      Offset(ox + dis * .10, _havluUst + 33),
      Offset(ox - dis * .60, _havluUst + 35),
      Offset(ox - dis * 1.00, _havluUst + 28),
      Offset(ox - dis * 1.02, _havluUst + 14),
    ),
    Offset(ox - dis * 1.02, _havluUst - 4),
  ];
}

/// One band of the towel's check.
///
/// A real woven grid was tried — two threads down, six across, both leaning
/// with the cloth. At the size he is actually seen the towel is thirty pixels
/// wide and the weave collapses into noise, and the threads that were meant
/// to run down it escaped past its hem. Three bands laid across the cloth is
/// what reads as a check from across the room, which is the only place anyone
/// sees it.
List<Offset> _havluCizgi(double yon, int i) {
  final ox = cx + yon * _havluX;
  final dis = yon * _havluYari;
  final y = _havluUst + (_havluAlt - _havluUst) * (.20 + i * .24);
  return serit(
    [
      Offset(ox + dis * .94, y - 3),
      Offset(ox - dis * 1.00, y + 3),
    ],
    2.7,
    2.7,
  );
}

/// The hand as a mitten with a thumb. An ellipse at this size reads as a
/// claw — the thumb is the only part that says hand, and it costs one lobe.
List<Offset> _el(double x, double y, double yon) => yol(
  Offset(x - yon * 11, y - 4),
  [
    [
      Offset(x - yon * 10, y - 15),
      Offset(x + yon * 6, y - 17),
      Offset(x + yon * 11, y - 7),
    ],
    [
      Offset(x + yon * 16, y + 2),
      Offset(x + yon * 14, y + 13),
      Offset(x + yon * 5, y + 16),
    ],
    [
      Offset(x - yon * 4, y + 18),
      Offset(x - yon * 11, y + 12),
      Offset(x - yon * 12, y + 4),
    ],
    // The thumb, hooked back over the shaft.
    [
      Offset(x - yon * 17, y + 3),
      Offset(x - yon * 18, y - 4),
      Offset(x - yon * 11, y - 4),
    ],
  ],
);

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

    // Trim is its own group because outlines all precede fills: on the
    // shirt's list the collar's and the apron's ink is painted out by the
    // shirt itself, which is why both read as flat stickers.
    sus.add(sekil(_boyun(), 'tenGolge', 0));
    for (final s in const [-1.0, 1.0]) {
      sus.add(sekil(_yaka(s), 'gomlek', _orta));
    }
    sus.add(sekil(_yakaPat(), 'gomlekG', _ince));
    final o = _onluk();
    sus
      ..add(sekil(o, 'onluk', _orta))
      ..add(sekil(hilal(o, a1: 120), 'onlukG', 0));

    // The towel crosses the apron, so it needs a group of its own too.
    havlu.add(sekil(_havlu(-1), 'havlu', _orta));
    for (var i = 0; i < 3; i++) {
      havlu.add(sekil(_havluCizgi(-1, i), 'havluCizgi', 0));
    }
    havlu.add(sekil(_havluKat(-1), 'havluG', _orta));

    // --- head ---------------------------------------------------------
    const kx = _r * _yanak + 3.5;
    final kf = _kafaSekli(cy);
    final yan = _sacYan(kf);
    // Ears first, behind the skull, the way the reference draws them: the
    // head's fill trims each ear to the crescent that clears the rim. In
    // front of the head they were outlined all the way round and read as
    // pebbles glued to the sides.
    for (final s in const [-1.0, 1.0]) {
      kafa
        ..add(sekil(elips(cx + s * kx, cy + 6, 16.5, 20.5), 'ten', _orta))
        ..add(sekil(_kulakIci(cx + s * kx, cy + 6, s), 'tenGolge', _orta));
    }
    kafa
      ..add(sekil(kf, 'ten', _siluet))
      ..add(sekil(hilal(kf, a0: -24, a1: 126, kalinlik: .20), 'tenGolge', 0))
      ..add(sekil(yan, 'sac', 0))
      ..add(sekil(ayna(yan), 'sac', 0))
      ..add(sekil(_sacTutam(kf), 'sac', 0))
      // Cheeks are his, not a mood: the reference has them and they are half
      // of why he reads as cheerful standing still.
      ..add(sekil(elips(cx - _gozAralik * 1.62, cy + 14, 15, 10), 'yanak', 0))
      ..add(sekil(elips(cx + _gozAralik * 1.62, cy + 14, 15, 10), 'yanak', 0));
    for (final s in const [-1.0, 1.0]) {
      kafa.add(sekil(_biyik(cy + 10, s), 'sac', _siluet));
    }
  }

  static final UstaParcalari tek = UstaParcalari._();

  final List<Sekil> govde = [];

  /// Collar, placket and apron: inside the shirt's silhouette, so they need a
  /// pass of their own or the shirt's fill eats their outlines.
  final List<Sekil> sus = [];
  final List<Sekil> havlu = [];
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
      ..add(sekil(_el(kol.el.dx, kol.el.dy, yon), 'ten', _orta));
    // He holds it up over the coals: the one piece of business the grill
    // does not hide, and the reason he reads as working at all.
    if (yon > 0) sisler.addAll(_sis(kol.el, 0.22).parca);
  }

  grup([...parca.govde.take(2), ...yenler, ...parca.govde.skip(2)]);
  grup(tenler);
  grup(sisler);
  grup(parca.sus);
  grup(parca.havlu);
  grup(parca.kafa);
  _yuz(canvas, p);
  canvas.restore();
}

/// The face, redrawn every frame because it is what carries him.
///
/// The nose and the mouth live here rather than with the head for a reason
/// that cost us a whole pass to find: the group draws every outline in one go
/// and only then every fill, so the skull — the first fill in its own list —
/// paints out the ink of anything lying wholly inside it. The old nose was a
/// darker oval with no line at all, and it disappeared.
void _yuz(Canvas canvas, UstaPoz p) {
  const cy = _kafaY;
  final ux = cx + p.hx;
  final uy = cy + p.hy;
  final ey = uy + _gozY;
  final acik = math.min<double>(1, math.max<double>(0, p.goz));

  final kalem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final bn = _burunSekli(ux, uy + _burunY);
  final burun = yoldan(bn);
  canvas
    ..drawPath(burun, Paint()..color = UstaPalet.ten)
    ..drawPath(
      yoldan(hilal(bn, a0: -44, a1: 92, kalinlik: .28)),
      Paint()..color = UstaPalet.tenGolge,
    )
    ..drawPath(
      burun,
      kalem
        ..color = const Color(0xFF2E2A26)
        ..strokeWidth = _orta,
    );

  // Eyes first, brows after: the reference's low brow sits *on* the eye and
  // clips its top, which only works if the brow is painted last.
  for (final yon in const [-1.0, 1.0]) {
    final ry = 3 + (_gozBoy - 3) * acik;
    canvas
      ..save()
      ..translate(ux + yon * _gozAralik, ey)
      // Both eyes lean the same way instead of mirroring: in the reference
      // the slant belongs to the head, and mirroring it reads as a squint.
      ..rotate(_gozEgim * math.pi / 180);
    final goz = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
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
      // One gaze for both eyes. Mirroring the offset is what made him look
      // through the player rather than at anything.
      const bakis = Offset(_bakisX, _bakisY);
      canvas
        ..drawOval(
          Rect.fromCenter(
            center: bakis,
            width: _bebek * 2,
            height: _bebekBoy * 2,
          ),
          Paint()..color = const Color(0xFF2E2A26),
        )
        // The cheapest pixels in the drawing, and the ones that make the eye
        // wet rather than printed.
        ..drawCircle(
          bakis + const Offset(3.2, -5.4),
          _isik,
          Paint()..color = const Color(0xFFFFFDF8),
        );
    }
    canvas.restore();
  }

  // He grins and both brows ride up, but the lead never closes — the lead is
  // the expression, not the height.
  final kalkOrtak = p.kas * 5 + (p.agiz - 7) * .35;
  for (final yon in const [-1.0, 1.0]) {
    final kalkti = yon < 0;
    canvas.drawPath(
      yoldan(
        _kas(
          ux + yon * _gozAralik,
          ey,
          yon,
          kalk: (kalkti ? _kasBoy : _kasBas) + kalkOrtak,
          ic: kalkti ? _kasIc : _kasIcBas,
        ),
      ),
      Paint()..color = UstaPalet.sac,
    );
  }

  // Open, under the moustache's parting. It is the two pale bands that make
  // it read: the old dark oval sat on black hair and differed from it by
  // twenty levels of red, so at any real size there was no mouth there.
  final gy = uy + _agizY;
  final gh = _agizBoy + p.agiz;
  final agiz = yoldan(_agizSekli(ux, gy, gh));
  canvas
    ..drawPath(agiz, Paint()..color = UstaPalet.agizIc)
    ..drawPath(yoldan(_disSekli(ux, gy, gh)), Paint()..color = UstaPalet.dis)
    ..drawPath(yoldan(_dilSekli(ux, gy, gh)), Paint()..color = UstaPalet.dil)
    ..drawPath(
      agiz,
      kalem
        ..color = const Color(0xFF2E2A26)
        ..strokeWidth = _orta,
    );
}
