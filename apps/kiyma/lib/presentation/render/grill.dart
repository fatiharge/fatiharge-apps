/// The mangal: a steel trough of coals, drawn from the same quad the slots
/// are cut from.
///
/// It was a painted layer, and the dependency ran the wrong way: the region
/// had been fitted to the picture, so moving a skewer meant re-fitting or
/// regenerating art. Drawn, the top face IS `mangal_alani`, the four slots
/// are that face divided, and moving one is a number.
///
/// Everything is built in the quad's own space — u across, v back-to-front —
/// so the perspective is the quad's and nothing here knows the angle. The
/// body is that face extruded straight down the screen, which is what the
/// room's own projection does with every other box in it.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/domain/quad.dart';

const _celikUst = Color(0xFF8A7C70);
const _celikGolge = Color(0xFF4A423C);
const _celikKoyu = Color(0xFF352F2A);
const _mure = Color(0xFF2A2420);
const _kul = Color(0xFF9A8F86);
const _kulKoyu = Color(0xFF6B625B);
const _korDip = Color(0xFF8E2A0C);
const _kor = Color(0xFFE8641A);
const _korSicak = Color(0xFFFFC24A);
const _alev = Color(0xFFFF9426);

/// Deterministic scatter. The coals must not reshuffle themselves every
/// frame, and a seeded Random would still have to be threaded through every
/// call — this is a pure function of the ember's index.
double _rast(int i) {
  final x = math.sin(i * 12.9898 + 4.1) * 43758.5453;
  return x - x.floorToDouble();
}

/// How deep the box is, down the screen. The painted one measured about this
/// and the room's skirting sits just under it, which is what made the old
/// chef look like he was standing in the room rather than on it.
const _derinlik = 40.0;
const _ayakBoyu = 56.0;

Path _yol(List<Offset> p) {
  final path = Path()..moveTo(p.first.dx, p.first.dy);
  for (var i = 1; i < p.length; i++) {
    path.lineTo(p[i].dx, p[i].dy);
  }
  return path..close();
}

/// A ring of embers filling the coal bed.
///
/// Irregular lumps rather than circles: a bed of discs reads as gravel. Each
/// one gets its own beat so the bed shimmers instead of pulsing as a sheet —
/// coals do not breathe in time with each other.
void _korCiz(Canvas canvas, Quad ust, double t, double isi) {
  const adet = 64;
  // A unit circle in (u, v) lands on screen as an ellipse, because the quad's
  // two axes are not the same length. This is the correction, and it was
  // inverted the first time — the coals came out as carrot slices.
  final boyu = (ust.at(1, .5) - ust.at(0, .5)).distance;
  final oran = boyu / (ust.at(.5, 1) - ust.at(.5, 0)).distance;
  for (var i = 0; i < adet; i++) {
    final u = .06 + _rast(i * 3) * .88;
    final v = .08 + _rast(i * 3 + 1) * .84;
    // Sized in screen pixels rather than in u: a coal is a coal whatever
    // shape the trough is, and as a fraction of the length it grew with the
    // trough until the bed read as one pool.
    final r = (3.0 + _rast(i * 3 + 2) * 3.8) / boyu;
    // Its own frequency and phase, so no two crest together for long.
    final atim =
        .5 +
        .5 * math.sin(t * (1.1 + _rast(i * 7) * 2.4) + _rast(i * 11) * 6.3);
    // Hotter in the middle, ashy at the rim, which is where a real bed is
    // coldest. The falloff is gentle: a sharp one left the whole bed grey
    // except a spot in the centre, and the coals read as gravel.
    // Banked along the trough rather than in a spot at its middle: the two
    // ends go ashy, the near and far rims cool faster than the length does.
    final orta = (1 - (u - .5).abs() * .75 - (v - .5).abs() * 1.05).clamp(
      0.0,
      1.0,
    );
    final sicak = (isi * (.45 + .55 * orta) * (.42 + .58 * atim)).clamp(
      0.0,
      1.0,
    );

    final nokta = <Offset>[];
    for (var j = 0; j < 9; j++) {
      final a = j / 9 * 2 * math.pi;
      final rr = r * (.68 + .32 * _rast(i * 31 + j));
      nokta.add(ust.at(u + rr * math.cos(a), v + rr * math.sin(a) * oran));
    }
    // Four stops, not two: ash to a dull red to ember to the yellow core.
    // Lerping straight from grey to orange gave a muddy brown at every middle
    // value, and the bed never looked lit.
    final kul = Color.lerp(_kulKoyu, _kul, _rast(i * 13))!;
    final renk = sicak < .34
        ? Color.lerp(kul, _korDip, sicak / .34)!
        : sicak < .70
        ? Color.lerp(_korDip, _kor, (sicak - .34) / .36)!
        : Color.lerp(_kor, _korSicak, (sicak - .70) / .30)!;
    canvas.drawPath(_yol(nokta), Paint()..color = renk);
    // The hottest carry a bright heart. It is what separates a lit coal from
    // an orange stone.
    if (sicak > .74) {
      canvas.drawPath(
        _yol([
          for (var j = 0; j < 7; j++)
            ust.at(
              u + r * .42 * math.cos(j / 7 * 2 * math.pi),
              v + r * .42 * math.sin(j / 7 * 2 * math.pi) * oran,
            ),
        ]),
        Paint()
          ..blendMode = BlendMode.plus
          ..color = _korSicak.withValues(alpha: .55 * (sicak - .74) / .26),
      );
    }
  }
}

/// Tongues of flame between the skewers.
///
/// Drawn additively and in front of the meat, because that is where a flame
/// on a mangal actually is. They are the only part of the grill that moves
/// fast: the coals shimmer, the fire flicks.
void alevCiz(Canvas canvas, Quad ust, double t, double isi) {
  if (isi <= .02) return;
  const adet = 7;
  for (var i = 0; i < adet; i++) {
    final u = .10 + i * .125 + _rast(i * 5) * .05;
    final v = .18 + _rast(i * 5 + 1) * .62;
    // Two beats again, so a tongue rises and falls unevenly.
    final can =
        (.28 +
            .72 *
                (.5 +
                    .5 *
                        math.sin(
                          t * (3.1 + _rast(i * 17) * 3.4) + _rast(i * 19) * 6.3,
                        ))) *
        isi;
    if (can < .12) continue;
    final boy = (.16 + .34 * can) * (.7 + .3 * _rast(i * 23));
    final en = .028 * (.7 + .5 * can);
    // The tip leans, and the lean changes: a flame that only grows and
    // shrinks reads as a bar chart.
    final egim = math.sin(t * 2.3 + i * 1.7) * .035;
    final dip = ust.at(u, v);
    final sol = ust.at(u - en, v);
    final sag = ust.at(u + en, v);
    final orta = ust.at(u + egim * .5, v);
    final tepe = Offset(
      orta.dx + egim * 90,
      dip.dy - boy * 190,
    );
    final bel = Offset(
      (sol.dx + sag.dx) / 2 + egim * 40,
      dip.dy - boy * 78,
    );
    canvas
      ..drawPath(
        Path()
          ..moveTo(sol.dx, sol.dy)
          ..quadraticBezierTo(bel.dx - 9, bel.dy, tepe.dx, tepe.dy)
          ..quadraticBezierTo(bel.dx + 9, bel.dy, sag.dx, sag.dy)
          ..close(),
        Paint()
          ..blendMode = BlendMode.plus
          ..color = _alev.withValues(alpha: .30 * can),
      )
      // A hotter core, shorter than the tongue around it.
      ..drawPath(
        Path()
          ..moveTo(sol.dx + (orta.dx - sol.dx) * .45, sol.dy)
          ..quadraticBezierTo(
            bel.dx,
            bel.dy + 6,
            orta.dx + egim * 44,
            dip.dy - boy * 108,
          )
          ..quadraticBezierTo(
            bel.dx + 4,
            bel.dy + 6,
            sag.dx - (sag.dx - orta.dx) * .45,
            sag.dy,
          )
          ..close(),
        Paint()
          ..blendMode = BlendMode.plus
          ..color = _korSicak.withValues(alpha: .26 * can),
      );
  }
}

/// The body of the grill, coals included. Drawn where the painted layer used
/// to blit, so everything in the room still lands in front of it.
void mangalCiz(
  Canvas canvas,
  Quad ust, {
  required double t,
  required double isi,
}) {
  // The rim stands a little outside the coal bed, which is what the skewers
  // rest on at both ends.
  Offset r(double u, double v) => ust.at(u, v);
  final kenar = [
    r(-.07, -.09),
    r(1.07, -.09),
    r(1.07, 1.09),
    r(-.07, 1.09),
  ];
  Offset asagi(Offset o, double d) => Offset(o.dx, o.dy + d);

  final ink = Paint()
    ..color = _mure
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 2.8;

  final merkez = kenar.reduce((a, b) => a + b) / 4;

  // --- legs, behind everything ----------------------------------------
  for (final a in kenar) {
    // The two back legs are shorter on screen because the floor they stand
    // on is further up it. Which two those are is read off the screen, not
    // off the corner order — the quad gets relabelled to steer the slots.
    final boy = a.dy < merkez.dy ? _ayakBoyu * .72 : _ayakBoyu;
    canvas
      ..drawPath(
        _yol([
          Offset(a.dx - 4, a.dy),
          Offset(a.dx + 4, a.dy),
          Offset(a.dx + 3, a.dy + boy + _derinlik),
          Offset(a.dx - 3, a.dy + boy + _derinlik),
        ]),
        Paint()..color = _celikGolge,
      )
      ..drawPath(
        _yol([
          Offset(a.dx - 4, a.dy),
          Offset(a.dx + 4, a.dy),
          Offset(a.dx + 3, a.dy + boy + _derinlik),
          Offset(a.dx - 3, a.dy + boy + _derinlik),
        ]),
        ink,
      );
  }

  // --- the box --------------------------------------------------------
  // Which walls the viewer can see, from each edge's outward normal. The
  // top face is a rectangle lying on the room's floor, which on screen is a
  // parallelogram — so both end edges have their midpoint at exactly the
  // centre's height, and comparing the two heights finds neither of them.
  // The box is extruded straight down, so a wall is visible when its normal
  // has any of that direction in it.
  final duvarlar = <({List<Offset> yuz, bool uzun})>[];
  for (var i = 0; i < 4; i++) {
    final a = kenar[i];
    final b = kenar[(i + 1) % 4];
    var disa = Offset(b.dy - a.dy, a.dx - b.dx);
    final govdeden = (a + b) / 2 - merkez;
    if (disa.dx * govdeden.dx + disa.dy * govdeden.dy < 0) disa = -disa;
    if (disa.dy <= 0) continue;
    duvarlar.add((
      yuz: [a, b, asagi(b, _derinlik), asagi(a, _derinlik)],
      // The long wall faces the room and the end wall turns away from it.
      uzun: (b.dx - a.dx).abs() > (b.dy - a.dy).abs(),
    ));
  }
  for (final d in duvarlar) {
    canvas.drawPath(
      _yol(d.yuz),
      Paint()..color = d.uzun ? _celikGolge : _celikKoyu,
    );
  }
  canvas
    // The coal bed, ash-dark before any ember lands on it.
    ..drawPath(_yol(kenar), Paint()..color = const Color(0xFF3A231A))
    // A warm floor under the coals: on a cold bed every ember read as a
    // spark on soot rather than as part of a fire.
    ..drawPath(
      _yol([
        ust.at(.06, .08),
        ust.at(.94, .08),
        ust.at(.94, .92),
        ust.at(.06, .92),
      ]),
      Paint()..color = Color.lerp(const Color(0xFF3A231A), _korDip, .55 * isi)!,
    );

  _korCiz(canvas, ust, t, isi);

  // --- the rim --------------------------------------------------------
  // Its own band rather than a stroke on the bed: a skewer lies ON it, and a
  // line has no top for anything to lie on.
  canvas.drawPath(_yol(kenar), ink);
  // A lit top edge on every wall the viewer can see: it is the one surface
  // the fire under it actually reaches. One path per wall — run into a
  // single one, the two bands join across the corner and fill the gap
  // between them.
  final tepe = Paint()..color = Color.lerp(_celikUst, _kor, .25 * isi)!;
  for (final d in duvarlar) {
    canvas
      ..drawPath(
        _yol([d.yuz[0], d.yuz[1], asagi(d.yuz[1], 5), asagi(d.yuz[0], 5)]),
        tepe,
      )
      ..drawPath(_yol(d.yuz), ink);
  }
}
