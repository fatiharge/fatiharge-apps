/// The customer's body, built from paths rather than loaded from a picture.
///
/// Every attempt to dress the rig in generated art failed for the same
/// reason: a finished drawing cannot be squashed, leaned or stretched, and
/// the whole language of this animation is exactly that. So the character is
/// geometry — the same flattened point lists the rig deforms every frame.
///
/// The figure lives in the seat's own space: 102.4 wide, the counter cutting
/// it at [kesim]. Nothing here knows about colour; every shape carries a role
/// name and the palette is chosen per customer, so three people at the
/// counter come out of one silhouette looking like three people.
library;

import 'dart:math' as math;
import 'dart:ui';

const cx = 51.0;

/// The counter's top edge in seat space. Everything below it is hidden, so
/// the body is drawn past it rather than stopping at it.
const kesim = 132.7;

/// The rail a hand rests on.
const ray = 129.7;

/// Ink weight, in four steps. One weight for everything was the single
/// biggest reason the drawing read as clip art: a 2.6 outline swallows a
/// tassel and looks thin on a silhouette. `yok` means no outline at all,
/// which inner shadows need — the two passes draw every outline before any
/// fill, so a shadow with its own line leaves dark smears across the face.
const siluet = 3.0;
const orta = 2.2;
const ince = 1.2;
const yok = 0.0;

/// One closed shape: where it is, what colour it asks for, how heavy its
/// outline is.
///
/// The path is built here rather than at draw time. The still parts never
/// move, so rebuilding a hundred points per shape per frame per customer was
/// paying for nothing.
typedef Sekil = ({Path yol, String rol, double kalem});

Sekil sekil(List<Offset> n, String rol, double kalem) =>
    (yol: yoldan(n), rol: rol, kalem: kalem);

Path yoldan(List<Offset> n) {
  // An empty list is a legitimate result: [hilal] returns one when the arc it
  // was asked for falls outside the shape. Drawing nothing is the right
  // answer, and crashing on it took out a whole frame.
  if (n.isEmpty) return Path();
  final p = Path()..moveTo(n.first.dx, n.first.dy);
  for (var i = 1; i < n.length; i++) {
    p.lineTo(n[i].dx, n[i].dy);
  }
  return p..close();
}

// The primitives below are public because the usta is built from the same
// vocabulary in his own file: he is a different person, not a fourteenth
// customer, but he is drawn with the same hand.

// --- path tools ------------------------------------------------------------

List<Offset> bez(Offset p0, Offset p1, Offset p2, Offset p3, [int n = 22]) {
  final out = <Offset>[];
  for (var i = 1; i <= n; i++) {
    final t = i / n;
    final u = 1 - t;
    final a = u * u * u;
    final b = 3 * u * u * t;
    final c = 3 * u * t * t;
    final d = t * t * t;
    out.add(
      Offset(
        a * p0.dx + b * p1.dx + c * p2.dx + d * p3.dx,
        a * p0.dy + b * p1.dy + c * p2.dy + d * p3.dy,
      ),
    );
  }
  return out;
}

List<Offset> yol(Offset bas, List<List<Offset>> segment) {
  final pts = <Offset>[bas];
  var cur = bas;
  for (final s in segment) {
    pts.addAll(bez(cur, s[0], s[1], s[2]));
    cur = s[2];
  }
  return pts;
}

List<Offset> elips(double x, double y, double rx, double ry) {
  const k = 0.5523;
  return yol(Offset(x, y - ry), [
    [Offset(x + rx * k, y - ry), Offset(x + rx, y - ry * k), Offset(x + rx, y)],
    [Offset(x + rx, y + ry * k), Offset(x + rx * k, y + ry), Offset(x, y + ry)],
    [Offset(x - rx * k, y + ry), Offset(x - rx, y + ry * k), Offset(x - rx, y)],
    [Offset(x - rx, y - ry * k), Offset(x - rx * k, y - ry), Offset(x, y - ry)],
  ]);
}

List<Offset> ayna(List<Offset> p) => [
  for (final q in p) Offset(2 * cx - q.dx, q.dy),
];

/// The run of a closed path between two angles, measured from its own centre.
List<Offset> _ark(List<Offset> pts, double a0, double a1) {
  var minX = double.infinity;
  var maxX = -double.infinity;
  var minY = double.infinity;
  var maxY = -double.infinity;
  for (final q in pts) {
    minX = math.min(minX, q.dx);
    maxX = math.max(maxX, q.dx);
    minY = math.min(minY, q.dy);
    maxY = math.max(maxY, q.dy);
  }
  final ox = (minX + maxX) / 2;
  final oy = (minY + maxY) / 2;
  const tam = 2 * math.pi;
  final genislik = (a1 - a0) % tam;
  bool icinde(Offset q) =>
      (math.atan2(q.dy - oy, q.dx - ox) - a0) % tam <= genislik;
  final n = pts.length;
  final b = [for (final q in pts) icinde(q)];
  var bas = 0;
  for (var i = 0; i < n; i++) {
    if (b[i] && !b[(i - 1 + n) % n]) {
      bas = i;
      break;
    }
  }
  final out = <Offset>[];
  var i = bas;
  while (b[i % n] && out.length < n) {
    out.add(pts[i % n]);
    i++;
  }
  return out;
}

/// A shadow that hugs the silhouette and tapers to nothing at both ends.
///
/// Cutting the shape with a straight line was tried first and the shadow's
/// inner edge read as a ruler drawn on the face. A real shadow edge follows
/// the form, so the inner edge is the outer edge pulled toward the centre,
/// furthest in the middle.
List<Offset> hilal(
  List<Offset> pts, {
  double a0 = -20,
  double a1 = 132,
  double kalinlik = 0.30,
}) {
  var minX = double.infinity;
  var maxX = -double.infinity;
  var minY = double.infinity;
  var maxY = -double.infinity;
  for (final q in pts) {
    minX = math.min(minX, q.dx);
    maxX = math.max(maxX, q.dx);
    minY = math.min(minY, q.dy);
    maxY = math.max(maxY, q.dy);
  }
  final ox = (minX + maxX) / 2;
  final oy = (minY + maxY) / 2;
  final ark = _ark(pts, a0 * math.pi / 180, a1 * math.pi / 180);
  if (ark.length < 4) return const [];
  final ic = <Offset>[];
  for (var i = 0; i < ark.length; i++) {
    final w =
        math.pow(math.max(0, math.sin(math.pi * i / (ark.length - 1))), 0.8) *
        kalinlik;
    ic.add(
      Offset(ox + (ark[i].dx - ox) * (1 - w), oy + (ark[i].dy - oy) * (1 - w)),
    );
  }
  return [...ark, ...ic.reversed];
}

/// The outline of a strip of varying width.
List<Offset> serit(List<Offset> orta, double w0, double w1) {
  final n = orta.length;
  final sol = <Offset>[];
  final sag = <Offset>[];
  for (var i = 0; i < n; i++) {
    final w = w0 + (w1 - w0) * (i / (n - 1));
    final j = math.max(1, math.min(i, n - 1));
    final d = orta[j] - orta[j - 1];
    final len = d.distance == 0 ? 1.0 : d.distance;
    final nx = -d.dy / len * w;
    final ny = d.dx / len * w;
    sol.add(Offset(orta[i].dx + nx, orta[i].dy + ny));
    sag.add(Offset(orta[i].dx - nx, orta[i].dy - ny));
  }
  return [...sol, ...sag.reversed];
}

/// The arm, shoulder to hand, as one curve.
///
/// A two-bone elbow was tried three times and broke three different ways.
/// The reason is not tuning: the elbow's swing off the axis goes as the
/// square root of the slack, so bones 5% longer than the reach throw it seven
/// units wide, and shorter bones cannot reach the counter at all. There is no
/// valid range between the two. The bend is now curvature rather than a
/// break — the closer the target, the more the curve bows out — and it never
/// corners.
({List<Offset> orta, Offset el}) kolEgrisi(
  Offset omuz,
  Offset hedef,
  double yon,
  double boy, {
  int n = 18,
}) {
  var d = (hedef - omuz).distance;
  var el = hedef;
  if (d < 1e-6) d = 1e-6;
  if (d > boy) {
    el = omuz + (hedef - omuz) * (boy / d);
    d = boy;
  }
  final u = (el - omuz) / d;
  final yay = boy * .62 * (1 - d / boy);
  final k = Offset(
    (omuz.dx + el.dx) / 2 + u.dy * yay * yon,
    (omuz.dy + el.dy) / 2 - u.dx * yay * yon,
  );
  final orta = <Offset>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final v = 1 - t;
    orta.add(
      Offset(
        v * v * omuz.dx + 2 * v * t * k.dx + t * t * el.dx,
        v * v * omuz.dy + 2 * v * t * k.dy + t * t * el.dy,
      ),
    );
  }
  return (orta: orta, el: el);
}

// --- parts -----------------------------------------------------------------

List<Offset> kafaSekli(
  double cy,
  double rx,
  double ry,
  double cene,
  double yanak,
) {
  final ust = cy - ry;
  final alt = cy + ry;
  final yx = rx * yanak;
  final ck = rx * cene;
  return yol(Offset(cx, ust), [
    [
      Offset(cx + rx * .66, ust),
      Offset(cx + yx, cy - ry * .52),
      Offset(cx + yx, cy + ry * .06),
    ],
    [
      Offset(cx + yx, cy + ry * .52),
      Offset(cx + ck * 1.06, alt - ry * .26),
      Offset(cx + ck * .66, alt - ry * .02),
    ],
    [
      Offset(cx + ck * .34, alt + ry * .10),
      Offset(cx - ck * .34, alt + ry * .10),
      Offset(cx - ck * .66, alt - ry * .02),
    ],
    [
      Offset(cx - ck * 1.06, alt - ry * .26),
      Offset(cx - yx, cy + ry * .52),
      Offset(cx - yx, cy + ry * .06),
    ],
    [
      Offset(cx - yx, cy - ry * .52),
      Offset(cx - rx * .66, ust),
      Offset(cx, ust),
    ],
  ]);
}

/// Shoulder to waist. The sides bow out and the shoulder-to-waist turn is a
/// curve, not a corner: as a plain trapezium it read as cut from card.
List<Offset> govdeSekli(
  double oy,
  double omuzYari,
  double altYari,
  double boyun,
) {
  const alt = 142.0;
  final sag = yol(Offset(cx + boyun, oy - 7.5), [
    [
      Offset(cx + omuzYari * .58, oy - 6.4),
      Offset(cx + omuzYari - 1.4, oy + 1.5),
      Offset(cx + omuzYari + .4, oy + 16),
    ],
    [
      Offset(cx + omuzYari + 2.2, oy + 29),
      Offset(cx + altYari - 1.2, alt - 28),
      Offset(cx + altYari, alt),
    ],
  ]);
  return [...ayna(sag).reversed, ...sag];
}

List<Offset> yakaSekli(double oy, double b, double s) => yol(
  Offset(cx + s * b * .52, oy - 7.5),
  [
    [
      Offset(cx + s * (b + 4), oy - 6.8),
      Offset(cx + s * (b + 7), oy - 2.6),
      Offset(cx + s * (b + 6.4), oy + 3.5),
    ],
    [
      Offset(cx + s * (b + 4.2), oy + 7),
      Offset(cx + s * 5.5, oy + 10.5),
      Offset(cx + s * 1.3, oy + 13),
    ],
    [
      Offset(cx + s * 1.3, oy + 7.5),
      Offset(cx + s * b * .46, oy + 1),
      Offset(cx + s * b * .52, oy - 7.5),
    ],
  ],
);

List<Offset> _pat(double oy) => [
  Offset(cx - 3.6, oy + 13),
  Offset(cx + 3.6, oy + 13),
  const Offset(cx + 3.9, 142),
  const Offset(cx - 3.9, 142),
];

List<Offset> _yelekKanat(double oy, double omuzYari, double altYari, double s) {
  const alt = 142.0;
  return [
    ...yol(Offset(cx + s * 7.5, oy - 3), [
      [
        Offset(cx + s * 20, oy + 1),
        Offset(cx + s * (omuzYari - 3.5), oy + 7),
        Offset(cx + s * (omuzYari - 1.6), oy + 18),
      ],
      [
        Offset(cx + s * (omuzYari + 1), oy + 30),
        Offset(cx + s * (altYari - 2.4), alt - 28),
        Offset(cx + s * (altYari - .6), alt),
      ],
    ]),
    Offset(cx + s * 9.5, alt),
    ...bez(
      Offset(cx + s * 9.5, alt),
      Offset(cx + s * 10, alt - 30),
      Offset(cx + s * 9.2, oy + 16),
      Offset(cx + s * 7.5, oy - 3),
    ),
  ];
}

/// One lobe of a handlebar. Drawn as a single path the dip in the middle
/// disappeared and the whole thing read as a wide bib.
List<Offset> biyikSekli(double y, double gen, double sarkma, double s) {
  final dip = y + sarkma * 1.02;
  final uc = y - sarkma * .92;
  return yol(Offset(cx + s * .45, y - sarkma * .20), [
    [
      Offset(cx + s * gen * .34, y - sarkma * .34),
      Offset(cx + s * gen * .74, y - sarkma * .62),
      Offset(cx + s * gen, uc),
    ],
    [
      Offset(cx + s * gen * 1.14, uc + sarkma * .34),
      Offset(cx + s * gen * 1.06, uc + sarkma * .78),
      Offset(cx + s * gen * .80, y + sarkma * .52),
    ],
    [
      Offset(cx + s * gen * .56, dip),
      Offset(cx + s * gen * .26, dip),
      Offset(cx + s * .6, y + sarkma * .50),
    ],
    [
      Offset(cx + s * .5, y + sarkma * .18),
      Offset(cx + s * .45, y - sarkma * .02),
      Offset(cx + s * .45, y - sarkma * .20),
    ],
  ]);
}

List<Offset> _fes(double alt, double r, double boy) {
  final tepe = alt - boy;
  return yol(Offset(cx - r, alt), [
    [
      Offset(cx - r * .99, alt - boy * .42),
      Offset(cx - r * .93, tepe + 5.5),
      Offset(cx - r * .80, tepe + 2.2),
    ],
    [
      Offset(cx - r * .58, tepe - 1.8),
      Offset(cx - r * .26, tepe - 3),
      Offset(cx, tepe - 3),
    ],
    [
      Offset(cx + r * .26, tepe - 3),
      Offset(cx + r * .58, tepe - 1.8),
      Offset(cx + r * .80, tepe + 2.2),
    ],
    [
      Offset(cx + r * .93, tepe + 5.5),
      Offset(cx + r * .99, alt - boy * .42),
      Offset(cx + r, alt),
    ],
  ]);
}

List<Offset> _fesBant(double alt, double r) => [
  Offset(cx - r, alt),
  Offset(cx + r, alt),
  Offset(cx + r * .975, alt - 6.4),
  Offset(cx - r * .975, alt - 6.4),
];

List<Offset> _kasket(double alt, double r, double boy) {
  final tepe = alt - boy;
  return [
    ...yol(Offset(cx - r, alt), [
      [
        Offset(cx - r * 1.02, tepe + 1),
        Offset(cx + r * .62, tepe - 1.5),
        Offset(cx + r * .80, alt - 2.8),
      ],
      [
        Offset(cx + r * 1.10, alt - 2.6),
        Offset(cx + r * 1.38, alt - 1),
        Offset(cx + r * 1.40, alt + .8),
      ],
    ]),
    ...bez(
      Offset(cx + r * 1.40, alt + .8),
      Offset(cx + r * 1.30, alt + 3.6),
      Offset(cx + r * .34, alt + 3.9),
      Offset(cx - r, alt),
    ),
  ];
}

/// A soft beanie: it sits on the skull and folds, where the fez stands up.
List<Offset> _bere(double alt, double r, double boy) {
  final tepe = alt - boy;
  return [
    ...yol(Offset(cx - r, alt), [
      [
        Offset(cx - r * 1.06, tepe + boy * .30),
        Offset(cx - r * .70, tepe),
        Offset(cx, tepe),
      ],
      [
        Offset(cx + r * .70, tepe),
        Offset(cx + r * 1.06, tepe + boy * .30),
        Offset(cx + r, alt),
      ],
    ]),
    Offset(cx + r * 1.04, alt + 3.4),
    Offset(cx - r * 1.04, alt + 3.4),
  ];
}

List<Offset> _sac(double cy, double rx, double ry) => yol(
  Offset(cx - rx, cy - ry * .26),
  [
    [
      Offset(cx - rx * 1.10, cy - ry * 1.16),
      Offset(cx + rx * 1.10, cy - ry * 1.16),
      Offset(cx + rx, cy - ry * .26),
    ],
    [
      Offset(cx + rx * .78, cy - ry * .64),
      Offset(cx + rx * .34, cy - ry * .40),
      Offset(cx + rx * .04, cy - ry * .60),
    ],
    [
      Offset(cx - rx * .30, cy - ry * .38),
      Offset(cx - rx * .74, cy - ry * .62),
      Offset(cx - rx, cy - ry * .26),
    ],
  ],
);

List<Offset> _sacParlak(double cy, double rx, double ry) => yol(
  Offset(cx - rx * .74, cy - ry * .80),
  [
    [
      Offset(cx - rx * .62, cy - ry * 1.06),
      Offset(cx - rx * .20, cy - ry * 1.14),
      Offset(cx + rx * .06, cy - ry * 1.02),
    ],
    [
      Offset(cx - rx * .18, cy - ry * .96),
      Offset(cx - rx * .48, cy - ry * .86),
      Offset(cx - rx * .74, cy - ry * .80),
    ],
  ],
);

/// A full beard: it follows the lower half of the skull and gathers under
/// the chin. Kept clear of the shoulders — hanging past them it read as a
/// bib rather than as hair.
List<Offset> _sakal(
  double cy,
  double rx,
  double ry,
  double cene,
  double yanak,
) {
  final yx = rx * yanak;
  final ck = rx * cene;
  return yol(Offset(cx - yx * .96, cy - ry * .04), [
    [
      Offset(cx - yx * 1.02, cy + ry * .68),
      Offset(cx - ck * .86, cy + ry * 1.18),
      Offset(cx, cy + ry * 1.24),
    ],
    [
      Offset(cx + ck * .86, cy + ry * 1.18),
      Offset(cx + yx * 1.02, cy + ry * .70),
      Offset(cx + yx * .96, cy - ry * .04),
    ],
    [
      Offset(cx + yx * .72, cy + ry * .30),
      Offset(cx + ck * .60, cy + ry * .62),
      Offset(cx, cy + ry * .66),
    ],
    [
      Offset(cx - ck * .60, cy + ry * .62),
      Offset(cx - yx * .72, cy + ry * .30),
      Offset(cx - yx * .96, cy - ry * .04),
    ],
  ]);
}

/// Hair falling past the shoulders. Drawn before the head, so the face lands
/// on top of it and only the sides show.
List<Offset> _uzunSac(double cy, double rx, double ry) => yol(
  Offset(cx - rx * 1.22, cy + ry * 1.85),
  [
    [
      Offset(cx - rx * 1.32, cy + ry * .30),
      Offset(cx - rx * 1.20, cy - ry * 1.06),
      Offset(cx, cy - ry * 1.24),
    ],
    [
      Offset(cx + rx * 1.20, cy - ry * 1.06),
      Offset(cx + rx * 1.32, cy + ry * .30),
      Offset(cx + rx * 1.22, cy + ry * 1.85),
    ],
    [
      Offset(cx + rx * .80, cy + ry * 1.70),
      Offset(cx - rx * .80, cy + ry * 1.70),
      Offset(cx - rx * 1.22, cy + ry * 1.85),
    ],
  ],
);

/// A headscarf: the path runs round the outside, then back in around the
/// opening the face shows through, and closes where it started. Two shapes
/// with a hole between them would need a fill rule; one boundary that
/// doubles back does the same job with the same machinery as a shadow.
///
/// The opening has to start at the hairline. Set higher it left the crown
/// bare and the scarf came out as a band round the face.
List<Offset> _esarp(double cy, double rx, double ry) => yol(
  Offset(cx - rx * 1.14, cy + ry * .72),
  [
    [
      Offset(cx - rx * 1.24, cy - ry * 1.12),
      Offset(cx + rx * 1.24, cy - ry * 1.12),
      Offset(cx + rx * 1.14, cy + ry * .72),
    ],
    [
      Offset(cx + rx * .98, cy + ry * .38),
      Offset(cx + rx * .90, cy + ry * .06),
      Offset(cx + rx * .86, cy - ry * .18),
    ],
    [
      Offset(cx + rx * .58, cy - ry * .44),
      Offset(cx - rx * .58, cy - ry * .44),
      Offset(cx - rx * .86, cy - ry * .18),
    ],
    [
      Offset(cx - rx * .90, cy + ry * .06),
      Offset(cx - rx * .98, cy + ry * .38),
      Offset(cx - rx * 1.14, cy + ry * .72),
    ],
  ],
);

/// A goatee: chin only, where the full beard takes the whole jaw.
List<Offset> _keciSakal(double cy, double rx, double ry, double cene) {
  final ck = rx * cene;
  return yol(Offset(cx - ck * .38, cy + ry * .60), [
    [
      Offset(cx - ck * .46, cy + ry * .94),
      Offset(cx - ck * .36, cy + ry * 1.24),
      Offset(cx, cy + ry * 1.28),
    ],
    [
      Offset(cx + ck * .36, cy + ry * 1.24),
      Offset(cx + ck * .46, cy + ry * .94),
      Offset(cx + ck * .38, cy + ry * .60),
    ],
    [
      Offset(cx + ck * .20, cy + ry * .74),
      Offset(cx - ck * .20, cy + ry * .74),
      Offset(cx - ck * .38, cy + ry * .60),
    ],
  ]);
}

List<Offset> _topuz(double cy, double rx, double ry) =>
    elips(cx + rx * .26, cy - ry * 1.20, rx * .36, ry * .32);

/// The fold inside the ear. A plain oval read as a button.
List<Offset> kulakIciSekli(double ex, double ey) => yol(
  Offset(ex + 3.4, ey - 3.8),
  [
    [
      Offset(ex + 1, ey - 3),
      Offset(ex + .7, ey + 2.2),
      Offset(ex + 3, ey + 3.6),
    ],
    [
      Offset(ex + 1.9, ey + 1.4),
      Offset(ex + 1.7, ey - 1.6),
      Offset(ex + 3.4, ey - 3.8),
    ],
  ],
);

// --- the people ------------------------------------------------------------

/// What makes one customer a different person from the next.
///
/// Only shape lives here. Colour is chosen per customer at draw time, so the
/// same silhouette turns up in a different shirt and a different skin without
/// a second entry in this table — which is what keeps seven types from
/// looking like seven repeats.
class FigureSpec {
  const FigureSpec({
    required this.kafaGen,
    required this.kafaBoy,
    required this.cene,
    required this.yanak,
    required this.omuzY,
    required this.omuzYari,
    required this.altYari,
    required this.gozR,
    required this.gozAralik,
    required this.burun,
    required this.burunY,
    this.kafaY = 40,
    this.burunOran = .84,
    this.kasKalin = 3.6,
    this.kasBoy = 5,
    this.sapka,
    this.sac = false,
    this.topuz = false,
    this.sakal = false,
    this.keci = false,
    this.uzunSac = false,
    this.gozluk = false,
    this.yelek = false,
    this.biyik,
    this.ak = false,
  });

  /// Head centre. A child is not a small adult: the whole figure sits lower,
  /// so they only just clear the counter.
  final double kafaY;
  final double kafaGen;
  final double kafaBoy;
  final double cene;
  final double yanak;
  final double omuzY;
  final double omuzYari;
  final double altYari;
  final double gozR;
  final double gozAralik;
  final double burun;
  final double burunY;
  final double burunOran;
  final double kasKalin;
  final double kasBoy;

  /// 'fes' | 'kasket' | 'bere', or none.
  final String? sapka;
  final bool sac;
  final bool topuz;
  final bool sakal;
  final bool keci;
  final bool uzunSac;

  /// Drawn with the face rather than with the head: glasses sit over the
  /// eyes, and the eyes are the one part redrawn every frame.
  final bool gozluk;
  final bool yelek;

  /// 'buyuk' | 'kucuk', or none.
  final String? biyik;

  /// Grey or white hair, so the palette stops rolling for a colour.
  final bool ak;

  /// A hanging arm, shoulder to wrist. Measured against the rail rather than
  /// fixed: from a shoulder at 80 and one at 86 the same number puts one
  /// hand on the counter and the other across the chest.
  double get kolBoyu => (ray - (omuzY + 10)) * .96;

  double get ceneY => kafaY + kafaBoy - 7;

  /// The top of the head, hat included — the ceiling clamp needs it.
  double get tepe =>
      kafaY -
      kafaBoy -
      switch (sapka) {
        'fes' => 19.0,
        'bere' => 17.0,
        'esarp' => 4.0,
        final s? when s.isNotEmpty => 13.0,
        _ => 0.0,
      };
}

const figurler = <String, FigureSpec>{
  'fesli': FigureSpec(
    kafaGen: 26,
    kafaBoy: 26,
    cene: .78,
    yanak: 1.04,
    omuzY: 76,
    omuzYari: 31,
    altYari: 38,
    gozR: 4,
    gozAralik: 9.5,
    burun: 9.4,
    burunY: 6,
    kasKalin: 4.2,
    kasBoy: 6,
    sapka: 'fes',
    biyik: 'buyuk',
    yelek: true,
    ak: true,
  ),
  'genc': FigureSpec(
    kafaGen: 24,
    kafaBoy: 26,
    cene: .70,
    yanak: 1,
    omuzY: 74,
    omuzYari: 29,
    altYari: 36,
    gozR: 6.8,
    gozAralik: 11.5,
    burun: 5.4,
    burunY: 7.5,
    sac: true,
    biyik: 'kucuk',
  ),
  'tombul': FigureSpec(
    kafaGen: 31,
    kafaBoy: 26,
    cene: 1,
    yanak: 1.14,
    omuzY: 70,
    omuzYari: 34,
    altYari: 41,
    gozR: 3.6,
    gozAralik: 10,
    burun: 4.6,
    burunY: 6.5,
    kasKalin: 3,
    kasBoy: 4,
    sapka: 'kasket',
  ),
  'zayif': FigureSpec(
    kafaGen: 22,
    kafaBoy: 27,
    cene: .62,
    yanak: .94,
    omuzY: 78,
    omuzYari: 26,
    altYari: 31,
    gozR: 3.4,
    gozAralik: 8.8,
    burun: 5,
    burunY: 8,
    burunOran: 1.45,
    kasKalin: 2.8,
    kasBoy: 4.4,
    sac: true,
    ak: true,
  ),
  'sakalli': FigureSpec(
    kafaGen: 25,
    kafaBoy: 26,
    cene: .90,
    yanak: 1.02,
    omuzY: 74,
    omuzYari: 32,
    altYari: 38,
    gozR: 4.6,
    gozAralik: 10.2,
    burun: 6.2,
    burunY: 6.4,
    kasKalin: 4,
    kasBoy: 5.2,
    sapka: 'bere',
    sakal: true,
    biyik: 'kucuk',
  ),
  'kadin': FigureSpec(
    kafaGen: 24,
    kafaBoy: 25,
    cene: .72,
    yanak: 1.06,
    omuzY: 78,
    omuzYari: 27,
    altYari: 33,
    gozR: 5.6,
    gozAralik: 10.4,
    burun: 4.4,
    burunY: 6.2,
    kasKalin: 2.6,
    sac: true,
    topuz: true,
  ),
  'cocuk': FigureSpec(
    kafaY: 53,
    kafaGen: 24,
    kafaBoy: 24,
    cene: .86,
    yanak: 1.08,
    omuzY: 96,
    omuzYari: 23,
    altYari: 27,
    gozR: 7.4,
    gozAralik: 11,
    burun: 3.8,
    burunY: 5.6,
    kasKalin: 2.6,
    kasBoy: 4.2,
    sapka: 'kasket',
  ),
  'gozluklu': FigureSpec(
    kafaGen: 23,
    kafaBoy: 26,
    cene: .68,
    yanak: .98,
    omuzY: 76,
    omuzYari: 28,
    altYari: 34,
    gozR: 4.4,
    gozAralik: 9.8,
    burun: 5.6,
    burunY: 7,
    kasKalin: 3,
    kasBoy: 4.6,
    sac: true,
    gozluk: true,
  ),
  'kel': FigureSpec(
    kafaGen: 29,
    kafaBoy: 25,
    cene: .96,
    yanak: 1.10,
    omuzY: 72,
    omuzYari: 33,
    altYari: 40,
    gozR: 3.8,
    gozAralik: 10.2,
    burun: 8.6,
    burunY: 6.2,
    kasKalin: 4.4,
    kasBoy: 5.6,
    biyik: 'buyuk',
    ak: true,
  ),
  'teyze': FigureSpec(
    kafaGen: 25,
    kafaBoy: 25,
    cene: .82,
    yanak: 1.08,
    omuzY: 78,
    omuzYari: 29,
    altYari: 36,
    gozR: 4.8,
    gozAralik: 10,
    burun: 5.2,
    burunY: 6.4,
    kasKalin: 2.8,
    kasBoy: 4.4,
    sapka: 'esarp',
  ),
  'genckiz': FigureSpec(
    kafaGen: 23,
    kafaBoy: 25,
    cene: .70,
    yanak: 1.02,
    omuzY: 78,
    omuzYari: 26,
    altYari: 32,
    gozR: 6.2,
    gozAralik: 10.6,
    burun: 4.2,
    burunY: 6,
    kasKalin: 2.4,
    kasBoy: 4.6,
    sac: true,
    uzunSac: true,
  ),
  'keci': FigureSpec(
    kafaGen: 24,
    kafaBoy: 26,
    cene: .64,
    yanak: 1,
    omuzY: 75,
    omuzYari: 29,
    altYari: 35,
    gozR: 5,
    gozAralik: 10.4,
    burun: 5.8,
    burunY: 6.8,
    kasKalin: 3.4,
    sac: true,
    keci: true,
    biyik: 'kucuk',
  ),
  // Tall: the head sits high and the shoulders drop, so the neck is long
  // even at rest — which is exactly the part of the rig that stretches.
  'uzunBoylu': FigureSpec(
    kafaY: 32,
    kafaGen: 23,
    kafaBoy: 25,
    cene: .70,
    yanak: .96,
    omuzY: 72,
    omuzYari: 27,
    altYari: 32,
    gozR: 4.2,
    gozAralik: 9.4,
    burun: 5.4,
    burunY: 7,
    kasKalin: 3,
    kasBoy: 4.8,
    sac: true,
    biyik: 'kucuk',
  ),
  // Short, but an adult: the moustache and the small eyes are what keep them
  // from reading as the child.
  'kisa': FigureSpec(
    kafaY: 50,
    kafaGen: 26,
    kafaBoy: 24,
    cene: .90,
    yanak: 1.06,
    omuzY: 92,
    omuzYari: 28,
    altYari: 33,
    gozR: 3.6,
    gozAralik: 9.6,
    burun: 6.4,
    burunY: 6,
    kasKalin: 3.8,
    sapka: 'kasket',
    biyik: 'buyuk',
  ),
};

/// The still parts of one figure, split the way the rig draws them: the body
/// group, then the head group. The neck and the arms are generated per frame
/// and go between the two, so they are not here.
class FigureParts {
  FigureParts(this.spec) {
    final cy = spec.kafaY;
    final rx = spec.kafaGen;
    final ry = spec.kafaBoy;
    final oy = spec.omuzY;
    const boyunYari = 11.0;

    final g = govdeSekli(oy, spec.omuzYari, spec.altYari, boyunYari);
    govde
      ..add(sekil(g, 'govde', siluet))
      ..add(sekil(hilal(g, a0: -18, a1: 128, kalinlik: .26), 'govdeG', yok));
    // The collar goes under the waistcoat: over it, it read as a scarf.
    for (final s in const [-1.0, 1.0]) {
      govde.add(sekil(yakaSekli(oy, boyunYari, s), 'govdeK', ince));
    }
    if (spec.yelek) {
      for (final s in const [-1.0, 1.0]) {
        final k = _yelekKanat(oy, spec.omuzYari, spec.altYari, s);
        govde.add(sekil(k, 'yelek', orta));
        if (s > 0) {
          govde.add(
            sekil(hilal(k, a0: -72, a1: 62, kalinlik: .24), 'yelekG', yok),
          );
        }
      }
    } else {
      govde.add(sekil(_pat(oy), 'govdeG', ince));
      for (var i = 0; i < 3; i++) {
        govde.add(sekil(elips(cx, oy + 27 + i * 18, 2, 2), 'govdeK', ince));
      }
    }

    if (spec.uzunSac) kafa.add(sekil(_uzunSac(cy, rx, ry), 'sac', orta));
    final kx = rx * spec.yanak - 1;
    for (final s in const [-1.0, 1.0]) {
      kafa.add(sekil(elips(cx + s * kx, cy + 3, 6.4, 7.4), 'ten', orta));
    }
    final kf = kafaSekli(cy, rx, ry, spec.cene, spec.yanak);
    kafa
      ..add(sekil(kf, 'ten', siluet))
      ..add(sekil(hilal(kf, a0: -24, a1: 126, kalinlik: .22), 'tenGolge', yok));
    final ki = kulakIciSekli(cx + kx, cy + 3.4);
    kafa
      ..add(sekil(ayna(ki), 'tenGolge', ince))
      ..add(sekil(ki, 'tenGolge', ince));
    // A beard is the same hair as the moustache, so it takes the same role.
    if (spec.sakal) {
      kafa.add(
        sekil(_sakal(cy, rx, ry, spec.cene, spec.yanak), 'biyikR', orta),
      );
    }
    if (spec.keci) {
      kafa.add(sekil(_keciSakal(cy, rx, ry, spec.cene), 'biyikR', orta));
    }
    if (spec.sac) {
      if (spec.topuz) kafa.add(sekil(_topuz(cy, rx, ry), 'sac', orta));
      kafa
        ..add(sekil(_sac(cy, rx, ry), 'sac', orta))
        ..add(sekil(_sacParlak(cy, rx, ry), 'sacG', yok));
    }
    switch (spec.sapka) {
      case 'fes':
        final taban = cy - ry + 4;
        final f = _fes(taban, rx * .68, 19);
        kafa
          ..add(sekil(f, 'sapkaR', orta))
          ..add(sekil(hilal(f, a0: -62, a1: 40, kalinlik: .26), 'sapkaG', yok))
          ..add(sekil(_fesBant(taban, rx * .68), 'sapkaK', ince))
          ..add(
            sekil(
              elips(cx + rx * .56, cy - ry - 13, 2.9, 2.9),
              'sapkaK',
              ince,
            ),
          );
      case 'bere':
        final b = _bere(cy - ry + 6, rx * .92, 17);
        kafa
          ..add(sekil(b, 'sapkaR', orta))
          ..add(sekil(hilal(b, a0: -58, a1: 46, kalinlik: .26), 'sapkaG', yok));
      case 'esarp':
        final e = _esarp(cy, rx, ry);
        kafa
          ..add(sekil(e, 'sapkaR', orta))
          ..add(sekil(hilal(e, a0: -40, a1: 70, kalinlik: .20), 'sapkaG', yok));
      case 'kasket':
        final k = _kasket(cy - ry + 5, rx * .84, 13);
        kafa
          ..add(sekil(k, 'sapkaR', orta))
          ..add(sekil(hilal(k, a0: -58, a1: 46, kalinlik: .24), 'sapkaG', yok));
    }
    kafa.add(
      sekil(
        elips(cx, cy + spec.burunY, spec.burun, spec.burun * spec.burunOran),
        'burunR',
        orta,
      ),
    );
    switch (spec.biyik) {
      case 'buyuk':
        for (final s in const [-1.0, 1.0]) {
          kafa.add(sekil(biyikSekli(cy + 9.4, 24.5, 9.4, s), 'biyikR', orta));
        }
      case 'kucuk':
        for (final s in const [-1.0, 1.0]) {
          kafa.add(sekil(biyikSekli(cy + 12.2, 9.5, 3.4, s), 'biyikR', orta));
        }
    }
  }

  /// Built once per type: the still parts never change, only the pose does.
  factory FigureParts.of(String ad) =>
      _onbellek[ad] ??= FigureParts(figurler[ad]!);

  static final Map<String, FigureParts> _onbellek = {};

  final FigureSpec spec;
  final List<Sekil> govde = [];
  final List<Sekil> kafa = [];
}

const figurAdlari = [
  'fesli',
  'genc',
  'tombul',
  'zayif',
  'sakalli',
  'kadin',
  'cocuk',
  'gozluklu',
  'kel',
  'teyze',
  'genckiz',
  'keci',
  'uzunBoylu',
  'kisa',
];
