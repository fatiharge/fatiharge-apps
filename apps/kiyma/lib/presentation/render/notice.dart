/// What the counter says out loud, said where it happened.
///
/// There was a toast: one grey pill, centred, replaced by whatever came next.
/// It had three problems. It sat over the tickets and the customers, which is
/// the half of the screen the player is reading. It looked the same whether
/// the news was a tip or a walk-out. And it was nowhere — a customer left,
/// and the sentence about it appeared in the middle of the room rather than
/// at the empty seat.
///
/// This is a badge in the scene instead: tone by colour, anchored to the
/// thing it is about, and it stacks rather than replacing, so two pieces of
/// news in the same second are both readable.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/presentation/render/painter.dart';

/// Good, bad, or "that will not work" — the three things the counter ever has
/// to say.
enum BildirimTonu { iyi, kotu, uyari }

const _mure = Color(0xFF2E2A26);
const _yazi = Color(0xFFFFF3E2);

const _dolgu = <BildirimTonu, Color>{
  BildirimTonu.iyi: Color(0xFF3F9A4E),
  BildirimTonu.kotu: Color(0xFFC4321F),
  BildirimTonu.uyari: Color(0xFFE0902A),
};

const _isik = <BildirimTonu, Color>{
  BildirimTonu.iyi: Color(0xFF57B767),
  BildirimTonu.kotu: Color(0xFFD9482F),
  BildirimTonu.uyari: Color(0xFFF2AC42),
};

const _yaziBoyu = 14.0;
const _yukseklik = 30.0;
const _isaretR = 9.0;

/// How wide the badge for [yazi] comes out. The caller needs this before the
/// badge exists, to keep it on screen and to stack it clear of its neighbour.
double bildirimEni(String yazi) =>
    _isaretR * 2 + 20 + textWidth(yazi, size: _yaziBoyu, weight: 800) + 14;

/// Whether the badge hangs under what it is about instead of standing on it.
///
/// The top of the frame is the order tickets and the faces under them, which
/// is the half of the screen being read under time pressure. A badge about
/// somebody at the counter stands on their head and on their ticket; hung, it
/// lands on the wooden ledge in front of them, where nothing is read.
bool bildirimAsili(Offset at, Size sahne) => at.dy < sahne.height * .42;

/// The badge's box: [at] is the thing it is about, and it sits clear of it on
/// whichever side [asili] says.
///
/// Pushed back inside the frame afterwards — several of these are about
/// something at the very edge of the scene, and a warning half off the screen
/// is not a warning.
Rect bildirimKutusu(
  Offset at,
  double en,
  Size sahne, {
  required bool asili,
}) {
  final x = at.dx.clamp(
    en / 2 + 8,
    math.max(en / 2 + 8, sahne.width - en / 2 - 8),
  );
  final ust = asili ? at.dy + 14 : at.dy - 14 - _yukseklik;
  return Rect.fromLTWH(
    x - en / 2,
    ust.clamp(8, math.max(8, sahne.height - _yukseklik - 8)),
    en,
    _yukseklik,
  );
}

/// How far a badge has to move to stand clear of what is already there.
///
/// Always away from the thing it is about, so a hung badge never crawls back
/// over the face it belongs to. [dolu] is everything it must miss: the badges
/// already up, and the boxes the HUD reads out of.
///
/// Four rows and then it gives up and overlaps — past that the stack is
/// taller than whatever it is pointing at, and hiding the room to explain the
/// room is not a trade worth making.
double bildirimKaymasi(Rect kasa, List<Rect> dolu, {required bool asili}) {
  final yon = asili ? 1.0 : -1.0;
  var kayma = 0.0;
  for (var i = 0; i < 4; i++) {
    if (!dolu.any(kasa.shift(Offset(0, yon * kayma)).overlaps)) break;
    kayma += kasa.height + 6;
  }
  return kayma;
}

/// Draws one badge. [t] runs 0…1 across its life; [kayma] moves it clear of
/// the badges already at the same place, away from the thing they are about.
void bildirimCiz(
  Canvas canvas,
  Rect kasa, {
  required String yazi,
  required BildirimTonu ton,
  required bool asili,
  required double t,
  double kayma = 0,
}) {
  // In on an overshoot, a slow drift while it is read, out upward. A badge
  // that only fades in is not noticed at the moment it appears, which is the
  // only moment it is worth anything.
  final giris = (t / .12).clamp(0.0, 1.0);
  final olcek = giris < 1 ? .62 + .38 * _geriTepme(giris) : 1.0;
  final cikis = ((t - .74) / .26).clamp(0.0, 1.0);
  final suzul = 6 * t + 12 * cikis * cikis;
  final alpha = (1 - cikis) * giris;
  if (alpha <= .01) return;

  // Both the drift and the stack step run away from the thing the badge is
  // about, so a hung one never crawls back over it.
  final yon = asili ? 1.0 : -1.0;
  final yer = kasa.shift(Offset(0, yon * (kayma + suzul)));
  canvas
    ..save()
    ..translate(yer.center.dx, yer.center.dy)
    ..scale(olcek)
    ..translate(-yer.center.dx, -yer.center.dy);

  final govde = RRect.fromRectAndRadius(
    yer,
    Radius.circular(yer.height / 2),
  );
  final renk = _dolgu[ton]!;
  canvas
    // The hard offset shadow every panel in this game has, so the badge is
    // the same object as the buttons and the tickets rather than a layer of
    // interface dropped on top of them.
    ..drawRRect(
      govde.shift(const Offset(0, 4)),
      Paint()..color = _mure.withValues(alpha: .55 * alpha),
    )
    ..drawRRect(govde, Paint()..color = renk.withValues(alpha: alpha))
    // A lit top half: flat colour at this size reads as a sticker.
    ..save()
    ..clipRRect(govde)
    ..drawRect(
      Rect.fromLTWH(yer.left, yer.top, yer.width, yer.height * .48),
      Paint()..color = _isik[ton]!.withValues(alpha: .55 * alpha),
    )
    ..restore()
    ..drawRRect(
      govde.deflate(1.5),
      Paint()
        ..color = _mure.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

  final isaret = Offset(yer.left + 6 + _isaretR, yer.center.dy);
  canvas.drawCircle(
    isaret,
    _isaretR,
    Paint()..color = _yazi.withValues(alpha: alpha),
  );
  _isaretCiz(canvas, ton, isaret, alpha);

  drawText(
    canvas,
    yazi,
    Offset(isaret.dx + _isaretR + 7, yer.center.dy),
    size: _yaziBoyu,
    weight: 800,
    family: 'Rubik',
    middle: true,
    color: _yazi.withValues(alpha: alpha),
  );
  canvas.restore();
}

/// Tick, cross, bang. Drawn rather than typed: three marks at eighteen pixels
/// have to be told apart at a glance, and a glyph from the text stack is a
/// different weight and a different centre in each of the two languages.
void _isaretCiz(Canvas canvas, BildirimTonu ton, Offset at, double alpha) {
  final kalem = Paint()
    ..color = _dolgu[ton]!.withValues(alpha: alpha)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 3;
  switch (ton) {
    case BildirimTonu.iyi:
      canvas.drawPath(
        Path()
          ..moveTo(at.dx - 4.4, at.dy + .4)
          ..lineTo(at.dx - 1.2, at.dy + 3.6)
          ..lineTo(at.dx + 4.6, at.dy - 3.6),
        kalem,
      );
    case BildirimTonu.kotu:
      canvas
        ..drawLine(
          at + const Offset(-3.6, -3.6),
          at + const Offset(3.6, 3.6),
          kalem,
        )
        ..drawLine(
          at + const Offset(3.6, -3.6),
          at + const Offset(-3.6, 3.6),
          kalem,
        );
    case BildirimTonu.uyari:
      canvas
        ..drawLine(
          at + const Offset(0, -4.6),
          at + const Offset(0, 1.2),
          kalem,
        )
        ..drawCircle(
          at + const Offset(0, 4.4),
          1.7,
          Paint()..color = _dolgu[ton]!.withValues(alpha: alpha),
        );
  }
}

/// `Curves.easeOutBack` without importing the animation library into a file
/// that draws.
double _geriTepme(double t) {
  const s = 1.70158;
  final u = t - 1;
  return u * u * ((s + 1) * u + s) + 1;
}
