/// The usta's speech bubble.
///
/// The lesson used to be a 500x92 panel in a corner with a painted portrait of
/// a chef in it — a different chef, in a different style, standing next to
/// the one who is actually in the room. Two cooks in one picture, and the
/// drawn one moving his mouth while the painted one talked.
///
/// So the portrait is gone and the man in the scene says it. The bubble is a
/// bubble: the same ink, the same cream and the same hard shadow as every
/// panel in the game, with a tail that points at his head — or, when the only
/// clear place to put it is across the room, three dots leading back to him,
/// which is the comic's own answer to the same problem.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/presentation/render/painter.dart';

const _mure = Color(0xFF2E2A26);
const _kagit = Color(0xFFF7EEDF);

const _yaziBoyu = 17.0;
const _bosluk = 18.0;

/// Past this the tail stops being a tail and becomes a trail of dots. A
/// triangle stretched across half the room is a wedge pointing nowhere.
const _kuyrukMenzili = 330.0;

/// How big a bubble holding [yazi] comes out, wrapped at [enCok].
Size balonBoyu(String yazi, {double enCok = 300}) {
  final m = textBox(yazi, size: _yaziBoyu, weight: 800, maxWidth: enCok);
  return Size(m.width + _bosluk * 2, m.height + _bosluk * 2 + 10);
}

/// Draws the bubble at [kasa], speaking from [agiz].
///
/// [adim] and [toplam] put the progress along the bottom as dots rather than
/// as "4/10": at this size the fraction was four characters nobody read, and
/// the dots say the same thing without being read at all.
void balonCiz(
  Canvas canvas,
  Rect kasa, {
  required String yazi,
  required Offset agiz,
  required int adim,
  required int toplam,
}) {
  final govde = RRect.fromRectAndRadius(kasa, const Radius.circular(16));
  final uzak = (kasa.center - agiz).distance > _kuyrukMenzili;

  // Tail first and filled with the same ink, so the body's own fill covers
  // where the two meet and the join never shows as a seam.
  final kuyruk = uzak ? null : _kuyruk(kasa, agiz);
  final golge = Paint()..color = _mure;
  canvas.drawRRect(govde.shift(const Offset(0, 6)), golge);
  if (kuyruk != null) {
    canvas.drawPath(kuyruk.shift(const Offset(0, 6)), golge);
  }
  canvas.drawRRect(govde, Paint()..color = _kagit);
  if (kuyruk != null) {
    canvas.drawPath(kuyruk, Paint()..color = _kagit);
  }
  // The outline goes on after both fills, as one stroke round each: drawn
  // before them, the body's fill ate the tail's own line.
  final kalem = Paint()
    ..color = _mure
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 3.4;
  if (kuyruk != null) canvas.drawPath(kuyruk, kalem);
  canvas
    ..drawRRect(govde.deflate(1.7), kalem)
    ..drawRRect(govde.deflate(5), Paint()..color = _kagit);

  if (uzak) _noktalar(canvas, kasa, agiz);

  drawText(
    canvas,
    yazi,
    Offset(kasa.left + _bosluk, kasa.top + _bosluk - 2),
    size: _yaziBoyu,
    weight: 800,
    family: 'Rubik',
    maxWidth: kasa.width - _bosluk * 2,
    color: _mure,
  );

  // The step count, as a row of pips on the bottom edge.
  for (var i = 0; i < toplam; i++) {
    final at = Offset(
      kasa.left + _bosluk + i * 9.0,
      kasa.bottom - _bosluk * .62,
    );
    if (at.dx > kasa.right - _bosluk) break;
    canvas.drawCircle(
      at,
      i == adim ? 3.4 : 2.4,
      Paint()
        ..color = i <= adim
            ? const Color(0xFFE0902A)
            : _mure.withValues(alpha: .22),
    );
  }
}

/// The wedge from the bubble to whoever is talking.
///
/// It leaves the edge nearest him rather than a fixed corner: the bubble
/// moves to whichever side of the room is free, and a tail welded to the
/// bottom-left points into space half the time.
Path _kuyruk(Rect kasa, Offset agiz) {
  final merkez = kasa.center;
  final yon = agiz - merkez;
  // Which edge it comes off: the one the speaker is past.
  final yatay = yon.dx.abs() / kasa.width > yon.dy.abs() / kasa.height;
  final Offset a;
  final Offset b;
  if (yatay) {
    final x = yon.dx < 0 ? kasa.left + 2 : kasa.right - 2;
    final y = agiz.dy.clamp(kasa.top + 18, kasa.bottom - 18);
    a = Offset(x, y - 11);
    b = Offset(x, y + 11);
  } else {
    final y = yon.dy < 0 ? kasa.top + 2 : kasa.bottom - 2;
    final x = agiz.dx.clamp(kasa.left + 18, kasa.right - 18);
    a = Offset(x - 11, y);
    b = Offset(x + 11, y);
  }
  // Stops well short of him: reaching the mouth it crossed a moustache half
  // again as wide as his own head and read as a spike through his cheek.
  final uc = agiz - (agiz - Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2)) * .34;
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(
      (a.dx + uc.dx) / 2,
      (a.dy + uc.dy) / 2,
      uc.dx,
      uc.dy,
    )
    ..quadraticBezierTo(
      (b.dx + uc.dx) / 2,
      (b.dy + uc.dy) / 2,
      b.dx,
      b.dy,
    )
    ..close();
}

/// Three dots, shrinking toward him. What a comic does when the speaker is
/// not next to the balloon.
void _noktalar(Canvas canvas, Rect kasa, Offset agiz) {
  final bas = Offset(
    agiz.dx < kasa.center.dx ? kasa.left : kasa.right,
    kasa.bottom,
  );
  for (var i = 0; i < 3; i++) {
    final t = .18 + i * .17;
    final at = Offset.lerp(bas, agiz, t)!;
    final r = 6.5 - i * 1.6;
    canvas
      ..drawCircle(at + const Offset(0, 5), r, Paint()..color = _mure)
      ..drawCircle(at, r, Paint()..color = _kagit)
      ..drawCircle(
        at,
        r,
        Paint()
          ..color = _mure
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
  }
}

/// Where the bubble can stand, best first.
///
/// The first three keep it beside him, which is where a speech bubble
/// belongs. The rest are the corners, for the steps whose target is where he
/// is — pointing at the grill with a bubble over the grill teaches nothing,
/// and that is the whole reason this is a search and not a position.
List<Rect> balonYerleri(Size sahne, Size boyut) {
  final w = boyut.width;
  final h = boyut.height;
  return [
    // Beside his head, over the tiles. Clear of him at x 304: overlapping
    // his own face is the one placement worse than every other.
    Rect.fromLTWH(304, 104, w, h),
    // Lower, over the ledge — clear of the tickets when somebody is waiting.
    Rect.fromLTWH(304, 218, w, h),
    // Above him. Tight: his hair starts at 138 and the meter ends at 72.
    Rect.fromLTWH(52, math.max(8, 132 - h), w, h),
    // And the far corners, where nothing else is free.
    Rect.fromLTWH(sahne.width - w - 20, 96, w, h),
    Rect.fromLTWH(sahne.width - w - 20, sahne.height - h - 26, w, h),
    Rect.fromLTWH(20, sahne.height - h - 26, w, h),
  ];
}
