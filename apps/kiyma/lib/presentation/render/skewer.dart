/// A skewer on the coals, drawn rather than picked from four pictures.
///
/// The four painted states were good, and they had three problems the art
/// could not solve. Cooking is continuous and the pictures were not, so the
/// meat jumped from raw to cooking to done in three steps. They were 64, 92,
/// 76 and 146 px tall, so it changed size as it changed state. And the burnt
/// one had its smoke painted in, which fixed the smoke to the sprite.
///
/// Drawn, the colour follows the two numbers the rules already keep: the meat
/// browns across `kizarma` and then darkens across `kavrulma` as the window
/// to take it runs out. That second ramp is the point — the player can watch
/// a skewer going, instead of reading a dial that tells them it went.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/domain/quad.dart';

/// Raw through cooked; the third stop is where it stops being pink.
const _cig = Color(0xFFEFB3AC);
const _cigGolge = Color(0xFFD9938C);
const _yariPismis = Color(0xFFC58C60);
const _pismis = Color(0xFFAA5029);
const _pismisGolge = Color(0xFF83381A);
const _kavruk = Color(0xFF3A2F2A);
const _kavrukGolge = Color(0xFF241D1A);
const _celik = Color(0xFFB4BAC0);
const _celikGolge = Color(0xFF8A9096);
const _mure = Color(0xFF2E2A26);

Color _et(double kizarma, double kavrulma) {
  final pisen = kizarma < .55
      ? Color.lerp(_cig, _yariPismis, kizarma / .55)!
      : Color.lerp(_yariPismis, _pismis, (kizarma - .55) / .45)!;
  return Color.lerp(pisen, _kavruk, kavrulma)!;
}

Color _etGolge(double kizarma, double kavrulma) {
  final pisen = kizarma < .55
      ? Color.lerp(_cigGolge, _yariPismis, kizarma / .55)!
      : Color.lerp(_yariPismis, _pismisGolge, (kizarma - .55) / .45)!;
  return Color.lerp(pisen, _kavrukGolge, kavrulma)!;
}

/// The mince, as a lump rather than a tube.
///
/// Adana is pressed on by hand and comes out ridged, so the half-height is a
/// sine along the length — seven swells, which is what the reference has —
/// tapered to nothing at both ends. A plain capsule read as a sausage.
List<Offset> _profil(double u0, double u1, double yari, double faz, double k) {
  // 44 samples aliased the second beat badly — under three samples per half
  // cycle — and the swells came out as sharp zigzags.
  const n = 84;
  final out = <Offset>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final u = u0 + (u1 - u0) * t;
    // Full along its whole length and rounded only at the last tenth. A
    // sine over the whole span gave a lens — thick in the middle, pointed at
    // both ends — which is a chilli, not a kofte.
    final uc = t < .10
        ? math.sin(t / .10 * math.pi / 2)
        : t > .90
        ? math.sin((1 - t) / .10 * math.pi / 2)
        : 1.0;
    // Two beats rather than one: pressed on by hand, the swells are uneven,
    // and a single sine reads as a machined ripple.
    final tumsek =
        .84 +
        .16 * math.sin(t * math.pi * 7 + faz) +
        .05 * math.sin(t * math.pi * 11 + 1.9);
    final h = yari * uc * tumsek;
    out.add(Offset(u, .5 - h * k));
  }
  return out;
}

/// The body, and the two bands that give it a round side: a lit crest and a
/// deeper underside. Two flat tones read as a sticker of meat — the light on
/// a coal grill comes from under it as well as over it, and the crest is what
/// says the lump is a lump.
({List<Offset> govde, List<Offset> isik, List<Offset> golge}) _etHatti(
  double u0,
  double u1,
  double yari,
  double faz,
) {
  List<Offset> p(double k) => _profil(u0, u1, yari, faz, k);
  final ust = p(1);
  final alt = [for (final o in p(1)) Offset(o.dx, 1 - o.dy)];
  return (
    govde: [...ust, ...alt.reversed],
    isik: [...p(.94), ...p(.34).reversed],
    golge: [
      for (final o in p(-.42)) Offset(o.dx, o.dy),
      ...[for (final o in p(-.97)) Offset(o.dx, o.dy)].reversed,
    ],
  );
}

Path _yol(Quad q, List<Offset> uv) {
  final p = Path();
  for (var i = 0; i < uv.length; i++) {
    final o = q.at(uv[i].dx, uv[i].dy);
    if (i == 0) {
      p.moveTo(o.dx, o.dy);
    } else {
      p.lineTo(o.dx, o.dy);
    }
  }
  return p..close();
}

/// Draws one skewer into its slot.
///
/// [kizarma] runs 0…1 from raw to the moment it is ready — `pismeOrani` on
/// the slot. [kavrulma] runs 0…1 across the window after that, and 1 once it
/// has burnt: how far gone it is.
void sisCiz(
  Canvas canvas,
  Quad slot, {
  required double kizarma,
  required double kavrulma,
}) {
  final k = kizarma.clamp(0.0, 1.0);
  final v = kavrulma.clamp(0.0, 1.0);

  // Meat gives up fat and shrinks. Small, but it is why a done skewer reads
  // as smaller than the raw one beside it without either changing size.
  final yari = .33 * (1 - .12 * k - .07 * v);

  final ink = Paint()
    ..color = _mure
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.6;

  // --- the steel ------------------------------------------------------
  // Drawn whole and then buried under the meat: the two ends have to line up
  // across the lump, and a shaft in two pieces never quite does.
  //
  // It runs past both rims, which is what a skewer resting on a trough does.
  // Contained inside the slot it read as floating in the fire, and it forced
  // the trough to be deep enough to hold it — a box rather than a trough.
  canvas
    ..drawPath(
      _yol(slot, const [
        Offset(-.19, .455),
        Offset(1.11, .455),
        Offset(1.11, .545),
        Offset(-.19, .545),
      ]),
      Paint()..color = _celik,
    )
    ..drawPath(
      _yol(slot, const [
        Offset(-.19, .505),
        Offset(1.11, .505),
        Offset(1.11, .545),
        Offset(-.19, .545),
      ]),
      Paint()..color = _celikGolge,
    )
    // The flattened tang, which is the end you hold.
    ..drawPath(
      _yol(slot, const [
        Offset(-.205, .50),
        Offset(-.135, .40),
        Offset(-.075, .40),
        Offset(-.075, .60),
        Offset(-.135, .60),
      ]),
      Paint()..color = _celik,
    )
    ..drawPath(
      _yol(slot, const [
        Offset(-.205, .50),
        Offset(-.135, .40),
        Offset(-.075, .40),
        Offset(-.075, .60),
        Offset(-.135, .60),
      ]),
      ink,
    );

  // --- the meat -------------------------------------------------------
  final et = _etHatti(.07, .93, yari, 0);
  final path = _yol(slot, et.govde);
  final ten = _et(k, v);
  canvas
    ..drawPath(path, Paint()..color = ten)
    ..drawPath(_yol(slot, et.golge), Paint()..color = _etGolge(k, v))
    // Char kills the shine before it kills the colour, so the crest fades out
    // ahead of everything else.
    ..drawPath(
      _yol(slot, et.isik),
      Paint()..color = Color.lerp(ten, const Color(0xFFFFE7C8), .26 * (1 - v))!,
    )
    ..drawPath(path, ink);

  // --- the bars it has been lying on ----------------------------------
  // They arrive with the browning and stay: a grill mark is a burn, and it
  // does not come back off.
  if (k > .28) {
    final iz = Paint()
      ..color = _kavrukGolge.withValues(alpha: (.20 + .55 * k).clamp(0.0, .78))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;
    for (var i = 0; i < 5; i++) {
      final u = .16 + i * .17;
      final a = slot.at(u - .022, .5 - yari * .74);
      final b = slot.at(u + .022, .5 + yari * .78);
      canvas.drawLine(a, b, iz);
    }
  }

  // --- fat catching the light ------------------------------------------
  // One speck on the crest of each swell. It arrives with the browning, which
  // is when the fat renders, and goes as the surface chars over.
  final parlak = (k - .35).clamp(0.0, 1.0) * (1 - v) * .8;
  if (parlak > .04) {
    final yag = Paint()
      ..color = const Color(0xFFFFF1DC).withValues(alpha: parlak);
    for (var i = 0; i < 4; i++) {
      final u = .18 + i * .21;
      canvas.drawPath(
        _yol(slot, [
          for (var j = 0; j <= 8; j++)
            Offset(
              u + .020 * math.cos(j / 8 * 2 * math.pi),
              .5 - yari * .52 + yari * .12 * math.sin(j / 8 * 2 * math.pi),
            ),
        ]),
        yag,
      );
    }
  }

  // --- char -----------------------------------------------------------
  // Blisters, not a wash: burning is local, and a uniformly darker skewer
  // reads as a different meat rather than as the same one going.
  if (v > .04) {
    final kara = Paint()..color = _kavrukGolge.withValues(alpha: .85 * v);
    for (var i = 0; i < 7; i++) {
      // A fixed scatter, so a skewer does not reshuffle its own scorch marks
      // every frame.
      final u = .12 + i * .125 + (i.isEven ? .014 : -.018);
      final w = (.012 + .022 * v) * (i.isEven ? 1.0 : .78);
      final h = yari * (.30 + .34 * v) * (i.isEven ? 1.0 : .82);
      final dy = (i % 3 - 1) * yari * .30;
      canvas.drawPath(
        _yol(slot, [
          for (var j = 0; j <= 10; j++)
            Offset(
              u + w * math.cos(j / 10 * 2 * math.pi),
              .5 + dy + h * math.sin(j / 10 * 2 * math.pi),
            ),
        ]),
        kara,
      );
    }
  }
}
