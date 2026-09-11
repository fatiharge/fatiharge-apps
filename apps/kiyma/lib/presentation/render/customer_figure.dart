import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/presentation/render/figure.dart';

const _mure = Color(0xFF2E2A26);

/// How angry each state is, `0..1`.
///
/// Colour is part of the gauge, not decoration: the pose reads from across
/// the screen, the flush reads up close, and the two say the same thing.
const _kizginlik = <CustomerMood, double>{
  CustomerMood.yuruyor: 0,
  CustomerMood.bekliyorCokSakin: 0,
  CustomerMood.bekliyorSakin: .12,
  CustomerMood.bekliyorStabil: .34,
  CustomerMood.bekliyorSupheli: .66,
  CustomerMood.bekliyorKizgin: 1,
  CustomerMood.gidiyorMutlu: 0,
  CustomerMood.gidiyorStabil: .18,
  CustomerMood.gidiyorKizgin: 1,
};

Color _karis(Color a, Color b, double u) => Color.lerp(a, b, u.clamp(0, 1))!;

/// The colours one customer is wearing.
///
/// Shapes carry role names, never colours, so the same silhouette turns up as
/// a different person every time. Shadow and detail tones are derived rather
/// than listed: the shirt colour is drawn at random, so a fixed shadow would
/// be wrong for seven of the eight shirts.
class CustomerPalette {
  CustomerPalette._({
    required this.ten,
    required this.tenGolge,
    required this.govde,
    required this.govdeG,
    required this.govdeK,
    required this.yelek,
    required this.yelekG,
    required this.sac,
    required this.sacG,
    required this.sapkaR,
    required this.sapkaG,
    required this.sapkaK,
  });

  /// Every field gets its own multiplier off the seed. One multiplier and the
  /// three people at the counter dress in the same order every run.
  factory CustomerPalette.forSeed(double tohum, {required bool ak}) {
    double frac(double v) => v - v.floorToDouble();
    T sec<T>(List<T> d, double k) => d[(frac(tohum * k) * d.length).floor()];

    final ten = sec(_tenler, 7.13);
    final govde = sec(_govdeler, 11.37);
    final yelek = sec(_yelekler, 5.29);
    // Grey belongs to the types that ask for it. Rolled freely it turned
    // the young man white and, on a light head, the hair shape reads as a
    // receding hairline rather than as hair.
    final sac = ak ? sec(_kirlar, 2.17) : sec(_saclar, 2.17);
    final sapka = sec(_sapkalar, 3.71);
    return CustomerPalette._(
      ten: ten,
      tenGolge: _karis(ten, _mure, .16),
      govde: govde,
      govdeG: _karis(govde, _mure, .17),
      govdeK: _karis(govde, _mure, .30),
      yelek: yelek,
      yelekG: _karis(yelek, _mure, .20),
      sac: sac,
      sacG: _karis(sac, const Color(0xFFFFFFFF), .20),
      sapkaR: sapka[0],
      sapkaG: _karis(sapka[0], _mure, .22),
      sapkaK: sapka[1],
    );
  }

  static const _tenler = [
    Color(0xFFEFC08D),
    Color(0xFFE3AF79),
    Color(0xFFC98A5B),
    Color(0xFFB0754A),
    Color(0xFFF3CB9E),
    Color(0xFFD9A26C),
  ];
  static const _govdeler = [
    Color(0xFFF4E9D2),
    Color(0xFF6E8B4A),
    Color(0xFFE0B341),
    Color(0xFF5E7FA8),
    Color(0xFFB8654A),
    Color(0xFF8A7CA8),
    Color(0xFFCFCAC0),
    Color(0xFF4F7A6B),
  ];
  static const _yelekler = [
    Color(0xFFC0453A),
    Color(0xFF7C5A34),
    Color(0xFF3F5E72),
    Color(0xFF6B4A6E),
    Color(0xFF2E2A26),
  ];
  static const _saclar = [
    Color(0xFF2B2320),
    Color(0xFF4A3428),
    Color(0xFF3A2F28),
    Color(0xFF5A4638),
  ];
  static const _kirlar = [
    Color(0xFF8C8378),
    Color(0xFFE8E2D6),
    Color(0xFFF6F3EC),
    Color(0xFFB6ADA2),
  ];
  static const _sapkalar = [
    [Color(0xFFB8392C), Color(0xFF8A2A20)],
    [Color(0xFF7C8B93), Color(0xFF5E6B72)],
    [Color(0xFF4F6B4A), Color(0xFF3A5138)],
    [Color(0xFF8A6A3A), Color(0xFF66502C)],
  ];
  static const _tenKizil = Color(0xFFC2402E);

  final Color ten;
  final Color tenGolge;
  final Color govde;
  final Color govdeG;
  final Color govdeK;
  final Color yelek;
  final Color yelekG;
  final Color sac;
  final Color sacG;
  final Color sapkaR;
  final Color sapkaG;
  final Color sapkaK;

  /// Only skin flushes. A shirt does not go red because its owner is waiting.
  Color rol(String ad, double kizgin) {
    final c = switch (ad) {
      'ten' => ten,
      'tenGolge' || 'burunR' => tenGolge,
      'govde' => govde,
      'govdeG' => govdeG,
      'govdeK' => govdeK,
      'yelek' => yelek,
      'yelekG' => yelekG,
      'sac' || 'biyikR' => sac,
      'sacG' => sacG,
      'sapkaR' => sapkaR,
      'sapkaG' => sapkaG,
      'sapkaK' => sapkaK,
      _ => const Color(0xFFFFFFFF),
    };
    return switch (ad) {
      'ten' || 'tenGolge' || 'burunR' => _karis(c, _tenKizil, kizgin * .34),
      _ => c,
    };
  }
}

/// One customer's pose for one frame.
///
/// The channels are the same ones the prototype animates, so a richer pose
/// table can be dropped in later without touching the drawing: lean, breath,
/// head offset, where each hand is, and the three numbers the face reads
/// from. What sets them here is the mood and the clock, nothing else.
class _Poz {
  _Poz(CustomerMood hal, double t, double faz) {
    final nefes = math.sin(t * 1.9 + faz);
    switch (hal) {
      case CustomerMood.yuruyor:
        dy = -1.6 * math.sin(t * 9 + faz).abs();
        egim = 1.4 * math.sin(t * 4.5 + faz);
        solAci = 8 + 26 * math.sin(t * 4.5 + faz);
        sagAci = 8 - 26 * math.sin(t * 4.5 + faz);
        agiz = 3;
      case CustomerMood.bekliyorCokSakin:
        dy = nefes * .8;
        agiz = 4.5;
      case CustomerMood.bekliyorSakin:
        dy = nefes * .9;
        hx = 1.6 * math.sin(t * .7 + faz);
        agiz = 3;
      case CustomerMood.bekliyorStabil:
        dy = nefes * 1.1;
        egim = -1.6;
        hy = 1.2;
        goz = .9;
        agiz = 0;
        // One hand goes on the rail: the first thing an impatient person does
        // is lean on something.
        sagEl = const Offset(90, ray);
      case CustomerMood.bekliyorSupheli:
        dy = nefes * 1.3;
        egim = -4;
        hy = 2.4;
        goz = .6;
        agiz = -3;
        solEl = const Offset(12, ray);
        // Drumming fingers: the hand itself keeps time.
        sagEl = Offset(90, ray - 2.2 * math.sin(t * 11 + faz).abs());
      case CustomerMood.bekliyorKizgin:
        final tremor = math.sin(t * 26 + faz);
        dx = tremor * 1.1;
        dy = nefes * 1.5;
        egim = -8 + tremor * .8;
        hy = 3.4;
        goz = .25;
        agiz = -6;
        kas = 3.4;
        solEl = Offset(12 + tremor, ray);
        sagEl = Offset(90 + tremor, ray);
      // The three leaving states all talk on the way out. A customer who
      // turns and walks off in silence tells the player nothing; the same
      // customer saying something tells them everything, and which of the
      // three it is comes off how hard the mouth is working.
      case CustomerMood.gidiyorMutlu:
        dy = -1.8 * math.sin(t * 9 + faz).abs();
        goz = 1.1;
        agiz = 6;
        agizAcik = _hece(t, faz, 7.5) * .45;
        solAci = 8 + 20 * math.sin(t * 4.5 + faz);
        sagAci = 8 - 20 * math.sin(t * 4.5 + faz);
      case CustomerMood.gidiyorStabil:
        dy = -1.2 * math.sin(t * 8 + faz).abs();
        egim = 1.6;
        agiz = -1;
        agizAcik = _hece(t, faz, 6.5) * .30;
        solAci = 8 + 14 * math.sin(t * 4 + faz);
        sagAci = 8 - 14 * math.sin(t * 4 + faz);
      case CustomerMood.gidiyorKizgin:
        dy = -2.2 * math.sin(t * 10 + faz).abs();
        egim = -7;
        goz = .2;
        agiz = -6;
        // Wide and fast, and it never quite shuts: this is the one the
        // player has to read from the other side of the counter.
        agizAcik = .34 + _hece(t, faz, 12) * .66;
        kas = 3.4;
        solAci = 8 + 34 * math.sin(t * 5 + faz);
        sagAci = 8 - 34 * math.sin(t * 5 + faz);
    }
    // A blink is cheap and it is what stops a still figure looking dead.
    final kirp = (math.sin(t * 1.13 + faz * 3) + 1) / 2;
    if (kirp > .985) goz *= .12;
  }

  /// Syllables. Two frequencies rather than one, because a mouth on a single
  /// sine is a fish; [faz] is the customer's own, so three of them leaving at
  /// once are not a chorus.
  static double _hece(double t, double faz, double hiz) =>
      (.5 +
              .34 * math.sin(t * hiz + faz * 2.7) +
              .16 * math.sin(t * hiz * .41 + faz))
          .clamp(0.0, 1.0);

  double dx = 0;
  double dy = 0;
  double egim = 0;
  double hx = 0;
  double hy = 0;
  double goz = 1;
  double agiz = 4;

  /// How far the mouth is open, 0…1. Separate from [agiz], which only bends
  /// the line between a smile and a scowl: a scowl and a shout are not the
  /// same face, and they were the same shape.
  double agizAcik = 0;
  double kas = 0;
  double solAci = 8;
  double sagAci = 8;
  Offset? solEl;
  Offset? sagEl;
}

/// Draws one customer at [kokta], in the seat's own 102.4-wide space.
///
/// Three groups, each with its own two passes — every outline, then every
/// fill. Later fills cover earlier outlines, which is what leaves one clean
/// silhouette instead of a double line between every pair of neighbours.
///
/// The arms are a group of their own for exactly that reason turned around:
/// drawn in the body's pass, the body's fill erased their outline and the arm
/// read as a lump stuck to the shirt rather than a limb.
void musteriCiz(
  Canvas canvas, {
  required Offset kokta,
  required String figur,
  required CustomerMood hal,
  required CustomerPalette palet,
  required double t,
  required double faz,
}) {
  final parca = FigureParts.of(figur);
  final K = parca.spec;
  final p = _Poz(hal, t, faz);
  final kz = _kizginlik[hal] ?? 0;

  final ink = Paint()
    ..color = _mure
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final inkDolgu = Paint()..color = _mure;

  void grup(List<Sekil> g) {
    for (final s in g) {
      if (s.kalem == 0) continue;
      canvas
        ..drawPath(s.yol, inkDolgu)
        ..drawPath(s.yol, ink..strokeWidth = s.kalem * 2);
    }
    for (final s in g) {
      canvas.drawPath(s.yol, Paint()..color = palet.rol(s.rol, kz));
    }
  }

  canvas
    ..save()
    ..translate(kokta.dx + p.dx, kokta.dy + p.dy)
    ..translate(cx, 122)
    ..rotate(p.egim * math.pi / 180)
    ..translate(-cx, -122);

  // --- the arms, as shapes -------------------------------------------------
  final yenler = <Sekil>[];
  final tenler = <Sekil>[];
  for (final yon in const [-1.0, 1.0]) {
    final omuz = Offset(cx + yon * (K.omuzYari + 1), K.omuzY + 10);
    final aci = (yon < 0 ? p.solAci : p.sagAci) * math.pi / 180;
    final hedef =
        (yon < 0 ? p.solEl : p.sagEl) ??
        Offset(
          omuz.dx + yon * math.sin(aci) * K.kolBoyu,
          omuz.dy + math.cos(aci) * K.kolBoyu,
        );
    final kol = kolEgrisi(omuz, hedef, yon, K.kolBoyu);
    final kes = math.max(3, (kol.orta.length * .46).round());
    // The sleeve starts inside the shirt so its flat end never shows.
    final ic = Offset(cx + yon * (K.omuzYari - 8), K.omuzY + 10);
    yenler.add(
      sekil(serit([ic, ...kol.orta.take(kes)], 8, 7.2), 'govde', orta),
    );
    tenler
      ..add(sekil(serit(kol.orta.sublist(kes - 1), 6.9, 5), 'ten', orta))
      ..add(
        sekil(
          [
            for (var i = 0; i < 24; i++)
              Offset(
                kol.el.dx + math.cos(i / 24 * 2 * math.pi) * 6.6,
                kol.el.dy + math.sin(i / 24 * 2 * math.pi) * 6.2,
              ),
          ],
          'ten',
          orta,
        ),
      );
  }

  // The neck and the sleeves belong to the body group: a sleeve is part of
  // the shirt, not of the arm, and the collar has to cover the neck's foot.
  // Drawn over the collar it left a hard horizontal line across the chest.
  final govde = [
    ...parca.govde.take(2),
    ..._boyun(K, p, kz),
    ...yenler,
    ...parca.govde.skip(2),
  ];

  grup(govde);
  grup(tenler);
  grup(parca.kafa);
  _yuz(canvas, K, p, palet, kz, t, faz);
  canvas.restore();
}

/// Chin to shoulders. A plain trapezium read as a slab bolted on: the sides
/// are concave and flare into the shoulders, and it is the same skin as the
/// face so the two passes fuse it to the head. The jaw line comes back from
/// the shadow band, because the neck's fill erases the head's outline.
List<Sekil> _boyun(FigureSpec K, _Poz p, double kz) {
  final ust = K.ceneY + p.hy;
  final alt = K.omuzY + 5;
  if (ust >= alt - 1) return const [];
  final h = alt - ust;
  const w0 = 8.4;
  const w1 = 12.4;
  final ux = cx + p.hx;
  final yol = <Offset>[
    Offset(ux - w0, ust),
    ..._bez2(
      Offset(ux - w0, ust),
      Offset(ux - w0 - .4, ust + h * .45),
      Offset(cx - w1 + .5, alt - h * .25),
      Offset(cx - w1, alt),
    ),
    Offset(cx + w1, alt),
    ..._bez2(
      Offset(cx + w1, alt),
      Offset(cx + w1 - .5, alt - h * .25),
      Offset(ux + w0 + .4, ust + h * .45),
      Offset(ux + w0, ust),
    ),
  ];
  final d = h * .70;
  final golge = <Offset>[
    Offset(ux - w0 - 1, ust - 5),
    Offset(ux + w0 + 1, ust - 5),
    ..._bez2(
      Offset(ux + w0 + 1, ust + d * .30),
      Offset(ux + w0 * .78, ust + d),
      Offset(ux - w0 * .78, ust + d),
      Offset(ux - w0 - 1, ust - 5),
    ),
  ];
  return [sekil(yol, 'ten', orta), sekil(golge, 'tenGolge', yok)];
}

List<Offset> _bez2(Offset p0, Offset p1, Offset p2, Offset p3, [int n = 14]) {
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

/// The face: the only part redrawn from scratch every frame, because it is
/// what carries the gauge. Brows follow the mouth — a sulking mouth pulls a
/// knitted brow — so one number sets both.
void _yuz(
  Canvas canvas,
  FigureSpec K,
  _Poz p,
  CustomerPalette palet,
  double kz,
  double t,
  double faz,
) {
  final cy = K.kafaY;
  final gr = K.gozR;
  final ar = K.gozAralik;
  final acik = math.max<double>(0, p.goz);
  final kasEgim = (-p.agiz * .42 + p.kas).clamp(-3.5, 3.5);

  final kalem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  for (final yon in const [-1.0, 1.0]) {
    final bx = cx + yon * ar;
    final by = cy - 4 - gr - K.kasBoy * .9;
    canvas.drawPath(
      Path()
        ..moveTo(bx - yon * gr * 1.2, by + K.kasBoy * .4 + kasEgim * yon)
        ..cubicTo(
          bx - yon * gr * .45,
          by - K.kasBoy * .6,
          bx + yon * gr * .45,
          by - K.kasBoy * .6,
          bx + yon * gr * 1.2,
          by + K.kasBoy * .4 - kasEgim * yon,
        ),
      kalem
        ..color = palet.rol('sac', 0)
        ..strokeWidth = K.kasKalin,
    );
  }

  for (final yon in const [-1.0, 1.0]) {
    final ex = cx + yon * ar;
    final ey = cy - 4;
    final ry = .9 + (gr - .5) * math.min(acik, 1.4);
    final goz = Path()
      ..addOval(
        Rect.fromCenter(center: Offset(ex, ey), width: gr * 2, height: ry * 2),
      );
    canvas
      ..drawPath(goz, Paint()..color = const Color(0xFFFFFFFF))
      ..drawPath(
        goz,
        kalem
          ..color = _mure
          ..strokeWidth = 1.7,
      );
    if (acik > .22) {
      final r = math.min(gr * .55, gr * .24 + gr * .38 * acik);
      canvas.drawCircle(
        Offset(ex + yon * gr * .2, ey + gr * .26),
        r,
        Paint()..color = _mure,
      );
    }
  }

  // Glasses go over the eyes and under everything the anger adds, so they
  // are drawn here rather than with the still parts of the head.
  if (K.gozluk) {
    // Heavier than they were, and square on the face that wears them for
    // work. Two thin wire rings at this size were a smudge, and the same
    // smudge on both of them.
    final r = gr * (K.kareGozluk ? 1.5 : 1.42);
    final cam = kalem
      ..color = const Color(0xFF3A322C)
      ..strokeWidth = K.kareGozluk ? 2.4 : 2.1;
    final dolgu = Paint()..color = const Color(0x18FFFFFF);
    for (final yon in const [-1.0, 1.0]) {
      final ex = cx + yon * ar;
      final merkez = Offset(ex, cy - 4);
      if (K.kareGozluk) {
        final kasa = RRect.fromRectAndRadius(
          Rect.fromCenter(center: merkez, width: r * 2.3, height: r * 1.75),
          const Radius.circular(2.4),
        );
        canvas
          ..drawRRect(kasa, dolgu)
          ..drawRRect(kasa, cam);
      } else {
        canvas
          ..drawCircle(merkez, r, dolgu)
          ..drawCircle(merkez, r, cam);
      }
      // The temple, off to the ear.
      canvas.drawLine(
        Offset(ex + yon * r * (K.kareGozluk ? 1.15 : 1), cy - 5),
        Offset(cx + yon * (K.kafaGen * K.yanak - 1), cy - 2),
        cam,
      );
    }
    canvas.drawLine(
      Offset(cx - ar + r * (K.kareGozluk ? 1.15 : 1), cy - 5.5),
      Offset(cx + ar - r * (K.kareGozluk ? 1.15 : 1), cy - 5.5),
      cam,
    );
  }

  // An open mouth, when there is something to say.
  //
  // Drawn for everybody including the handlebars: the moustache sits four
  // pixels higher and covers the top lip, which is exactly what a moustache
  // does — the opening below it still reads. The closed line below is the one
  // a handlebar genuinely swallows, and that one is still skipped.
  if (p.agizAcik > .04) {
    final h = 1.6 + 7.4 * p.agizAcik;
    final w = 7.4 + 2.2 * p.agizAcik;
    final agiz = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 18 + h * .35),
          width: w * 2,
          height: h * 2,
        ),
      );
    canvas
      ..drawPath(agiz, Paint()..color = const Color(0xFF6E2317))
      // The tongue. It is the whole difference between a mouth and a hole,
      // and at this size it is one shape.
      ..drawPath(
        Path()..addOval(
          Rect.fromCenter(
            center: Offset(cx, cy + 18 + h * .95),
            width: w * 1.25,
            height: h * .78,
          ),
        ),
        Paint()..color = const Color(0xFFC4574A),
      )
      ..drawPath(
        agiz,
        kalem
          ..color = _mure
          ..strokeWidth = 2.4,
      );
  } else if (K.biyik != 'buyuk') {
    // A big handlebar already covers the mouth; a line under it says nothing.
    canvas.drawPath(
      Path()
        ..moveTo(cx - 8, cy + 17)
        ..cubicTo(
          cx - 3,
          cy + 17 + p.agiz * 1.4,
          cx + 3,
          cy + 17 + p.agiz * 1.4,
          cx + 8,
          cy + 17,
        ),
      kalem
        ..color = _mure
        ..strokeWidth = 3,
    );
  }

  if (kz <= .05) return;

  // Cheeks and a bead of sweat: the same reading as the pose, up close.
  final yanak = Paint()
    ..color = const Color(0xFFC9503A).withValues(alpha: math.min(.62, kz * .7));
  for (final yon in const [-1.0, 1.0]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + yon * ar * 1.42, cy + 5),
        width: 10.8,
        height: 7.6,
      ),
      yanak,
    );
  }
  if (kz > .5) {
    final dus = (t * .55 + faz) % 1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + ar * 1.9, cy - 18 + dus * 26),
        width: 5.2,
        height: 7.2,
      ),
      Paint()
        ..color = const Color(0xFFBFE3F2).withValues(alpha: .8 * (1 - dus)),
    );
  }

  // At the top of the anger the eyes burn. Beams were tried and looked silly:
  // they cover the face and cut the frame in two. A glow is calmer and it
  // marks that seat in red from across the screen. Additive blending was
  // tried too and washes the red out on light skin — the channels are already
  // high, so they saturate to white. Plain alpha is the right tool.
  final lz = ((kz - .62) / .38).clamp(0.0, 1.0);
  if (lz <= .01) return;
  final atim = 1 + .10 * math.sin(t * 13 + faz);
  for (final yon in const [-1.0, 1.0]) {
    final ex = cx + yon * ar;
    final ey = cy - 4;
    for (final (kat, renk, a) in const [
      (1.46, Color(0xFFD03A22), .42),
      (0.98, Color(0xFFF2502E), .90),
    ]) {
      canvas.drawCircle(
        Offset(ex, ey),
        gr * kat * atim,
        Paint()..color = renk.withValues(alpha: a * lz),
      );
    }
    // The pupil sits on top of the glow, or the eye is an empty disc.
    final r = math.min(gr * .55, gr * .24 + gr * .38 * acik);
    canvas
      ..drawCircle(
        Offset(ex + yon * gr * .2, ey + gr * .26),
        r,
        Paint()..color = const Color(0xFF2A1512).withValues(alpha: lz),
      )
      ..drawCircle(
        Offset(ex - yon * gr * .26, ey - gr * .30),
        gr * .22,
        Paint()..color = const Color(0xFFFFE9C0).withValues(alpha: .85 * lz),
      );
  }
}
