/// The run's momentum, as a segmented meter hung on the wall.
///
/// It has been three shapes. A dial needed no explaining but ate the corner
/// the usta now stands in and had to be looked at to be read. A plain line
/// welded to the top of the screen was read without looking, and said nothing
/// about how much of the meter one serve was worth. This is the third: ten
/// segments, so the level can be counted rather than estimated, with the
/// partial one showing exactly where the value sits.
///
/// Drawn rather than assembled from Flame components. Everything in this game
/// is painted by one component in a fixed order — the counter says why — so
/// sprites, priorities and effects would buy lifecycle management for a
/// z-order that is four lines here.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Curves, IconData, Icons;
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/presentation/render/painter.dart';

/// One place for the meter's colours.
abstract final class TempoRenk {
  static const kontur = Color(0xFF14171B);
  static const kasa = Color(0xFF3D444E);
  static const iz = Color(0xFF1A1D22);
  static const bosSlot = Color(0xFF2B3038);

  static const soguk = Color(0xFF6CC4FF);
  static const normal = Color(0xFFFFC233);
  static const isiniyor = Color(0xFFFF9426);
  static const ates = Color(0xFFFF5A24);

  static const sogukHale = Color(0xFF5FB6FF);
  static const sicakHale = Color(0xFFFF7A1A);

  static const Map<TempoBand, Color> bant = {
    TempoBand.soguk: soguk,
    TempoBand.normal: normal,
    TempoBand.isiniyor: isiniyor,
    TempoBand.ates: ates,
  };

  /// The band, named. A word here would need translating and would not be
  /// read at a glance anyway.
  static const Map<TempoBand, IconData> glif = {
    TempoBand.soguk: Icons.ac_unit_rounded,
    TempoBand.normal: Icons.thermostat_rounded,
    TempoBand.isiniyor: Icons.whatshot_rounded,
    TempoBand.ates: Icons.local_fire_department_rounded,
  };
}

/// How full segment [i] of ten is at [deger].
///
/// Deliberately not rounded to whole segments: a half-lit segment is the
/// needle, and rounding it away turns a meter into a step counter.
double segmentDolulugu(double deger, int i) =>
    ((deger - i * 10) / 10).clamp(0.0, 1.0);

/// Frost spikes: seven from the top edge, seven from the bottom, fixed rather
/// than rolled. Rime is not a starburst, and a meter that reshuffles its own
/// ice every frame is a screensaver.
const _kiragiUst = [0.08, 0.22, 0.37, 0.50, 0.64, 0.79, 0.93];
const _kiragiUstBoy = [0.9, 0.6, 1.0, 0.7, 0.9, 0.5, 0.8];
const _kiragiAlt = [0.14, 0.29, 0.43, 0.57, 0.71, 0.85, 0.97];
const _kiragiAltBoy = [0.7, 1.0, 0.6, 0.9, 0.6, 1.0, 0.7];

/// The hard cap on how far frost may grow, as a fraction of the track.
///
/// Enforced here rather than trusted to the numbers above: the lit strip down
/// the middle must survive any amount of cold. A meter you cannot read is a
/// bug, not a mood.
const kiragiTavani = 0.30;

double kiragiBoyu(double taban, double k, double izYuksekligi) =>
    math.min(taban * k, izYuksekligi * kiragiTavani);

/// Six flame tongues, spread along the track at fixed places with their own
/// frequencies and phases, so no two lick together for long.
const _alevYeri = [0.08, 0.25, 0.42, 0.60, 0.76, 0.92];
const _alevHizi = [1.11, 0.92, 1.25, 1.03, 0.86, 1.18];
const _alevFazi = [0.0, 2.1, 4.0, 1.2, 5.3, 3.1];

/// What has to survive between frames. The value the meter shows chases the
/// real one, the band remembers itself so the hysteresis has something to be
/// hysteretic about, and the three timers are the beats.
class TempoBarDurumu {
  /// Seeded on the first tick rather than at construction. A meter that
  /// opens at the halfway mark and slides to the real value is lying for the
  /// first fifth of a second of every run.
  double gorunen = Tempo.baslangic;
  TempoBand bant = TempoBand.normal;
  bool _kuruldu = false;

  /// Seconds left of the band-change pop, the pulse ring, and the bounce of
  /// whichever segment the value landed in.
  double pop = 0;
  double halka = 0;
  double ziplama = 0;
  int ziplayan = 0;

  /// Where the pulse ring is, kept from the frame the delta arrived so it
  /// does not slide while the fill eases toward its new value.
  double halkaX = 0;

  /// Snap to the real value, once. Safe to call every frame.
  void kur(Tempo tempo) {
    if (_kuruldu) return;
    _kuruldu = true;
    gorunen = tempo.deger;
    bant = Tempo.bantGecisi(tempo.deger, TempoBand.normal);
  }

  void tick(double dt, Tempo tempo) {
    if (!_kuruldu) {
      kur(tempo);
      return;
    }
    // ~180 ms to close the gap, so a serve is a move rather than a jump.
    gorunen += (tempo.deger - gorunen) * (1 - math.exp(-dt / 0.06));
    final yeni = Tempo.bantGecisi(tempo.deger, bant);
    if (yeni != bant) {
      bant = yeni;
      pop = 0.4;
    }
    if (pop > 0) pop -= dt;
    if (halka > 0) halka -= dt;
    if (ziplama > 0) ziplama -= dt;
  }

  /// A change landed: ring, and bounce the segment it landed in.
  void darbe(double deger, double izSol, double izGen) {
    halka = 0.45;
    ziplama = 0.25;
    halkaX = izSol + izGen * (deger / 100).clamp(0.0, 1.0);
    ziplayan = (deger / 10).clamp(0.0, 9.0).floor();
  }
}

/// Draws the meter into [kasa]. Every measure is a fraction of the case's
/// height, so the whole thing scales by changing one rectangle.
void tempoBariCiz(
  Canvas canvas,
  Rect kasa, {
  required Tempo tempo,
  required TempoBarDurumu durum,
  required double t,
  Image? alev,
}) {
  final h = kasa.height;
  final renk = TempoRenk.bant[durum.bant]!;
  final v = durum.gorunen;
  final ham = tempo.deger;

  // Continuous parts read the real value, not the eased one: they fade to
  // nothing at their own thresholds, so there is nothing to flicker.
  final sicak = ham > 60 ? ((ham - 60) / 40 * .85).clamp(0.0, 1.0) : 0.0;
  final soguk = ham < 25 ? ((25 - ham) / 25 * .75).clamp(0.0, 1.0) : 0.0;
  final k = ham < 25 ? (25 - ham) / 25 : 0.0;

  final kontur = Paint()
    ..color = TempoRenk.kontur
    ..style = PaintingStyle.stroke
    ..strokeWidth = h * .07;

  // --- glow, behind everything ----------------------------------------
  if (sicak > 0 || soguk > 0) {
    // Warm breathes, cold does not: a cold meter is still.
    final atim = sicak > 0 ? 1 + .07 * math.sin(t * 5.7) : 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        kasa.inflate(h * .18 * atim),
        Radius.circular(h * .42),
      ),
      Paint()
        ..color = (sicak > 0 ? TempoRenk.sicakHale : TempoRenk.sogukHale)
            .withValues(
              alpha: sicak > 0 ? sicak * .5 : soguk * .45,
            )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * .22 * atim),
    );
  }

  // --- flame tongues, rising from behind the case ----------------------
  if (alev != null && ham >= 90) {
    final guc = ((ham - 90) / 10).clamp(0.0, 1.0);
    final olcek = .6 + guc * .6;
    for (var i = 0; i < 6; i++) {
      final lick = .55 + .45 * math.sin(t * _alevHizi[i] * 5 + _alevFazi[i]);
      final boy = h * olcek * (.55 + .45 * lick);
      // Taller means narrower: a flame stretches, it does not inflate.
      final en = h * olcek * .46 / (.7 + .3 * lick);
      final x = kasa.left + kasa.width * _alevYeri[i];
      // Drawn straight into a destination rect: a tongue has to stretch in
      // one axis and pinch in the other, and the shared helper derives its
      // height from the image's own aspect.
      canvas.drawImageRect(
        alev,
        Rect.fromLTWH(0, 0, alev.width.toDouble(), alev.height.toDouble()),
        Rect.fromLTWH(x - en / 2, kasa.top + h * .18 - boy, en, boy),
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: guc)
          ..filterQuality = FilterQuality.low,
      );
    }
  }

  // --- the case --------------------------------------------------------
  final govde = RRect.fromRectAndRadius(kasa, Radius.circular(h * .32));
  canvas
    // Hard shadow, not blurred: everything here has an ink line round it and
    // a soft shadow under that reads as a different picture.
    ..drawRRect(
      govde.shift(Offset(0, h * .11)),
      Paint()..color = TempoRenk.kontur,
    )
    ..drawRRect(govde, Paint()..color = TempoRenk.kasa)
    ..drawRRect(govde, kontur);

  // --- the track -------------------------------------------------------
  final iz = Rect.fromLTRB(
    kasa.left + h * .71,
    kasa.top + h * .125,
    kasa.right - h * .14,
    kasa.bottom - h * .125,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(iz, Radius.circular(h * .10)),
    Paint()..color = TempoRenk.iz,
  );

  // --- ten segments ----------------------------------------------------
  final bosluk = h * .07;
  final segGen = (iz.width - bosluk * 9) / 10;
  final segYari = Radius.circular(h * .09);
  for (var i = 0; i < 10; i++) {
    final sol = iz.left + i * (segGen + bosluk);
    final kutu = Rect.fromLTWH(sol, iz.top, segGen, iz.height);
    final yuvarlak = RRect.fromRectAndRadius(kutu, segYari);
    canvas.drawRRect(yuvarlak, Paint()..color = TempoRenk.bosSlot);

    final oran = segmentDolulugu(v, i);
    if (oran <= 0) continue;

    var olcekY = 1.0;
    if (durum.ziplama > 0 && durum.ziplayan == i) {
      olcekY = 1 + .28 * Curves.easeOut.transform(durum.ziplama / .25);
    }
    // The last one trembles while the meter is pinned. Pinned is a state,
    // not a stop — the dial's needle said the same thing.
    var olcekX = 1.0;
    if (ham >= 99.5 && i == 9) {
      olcekX = .9 + .1 * (.5 + .5 * math.sin(t * 31));
    }

    canvas
      ..save()
      ..clipRRect(yuvarlak)
      ..translate(kutu.left, kutu.center.dy)
      ..scale(olcekX, olcekY)
      ..translate(-kutu.left, -kutu.center.dy);
    final dolu = Rect.fromLTWH(kutu.left, kutu.top, segGen * oran, kutu.height);
    canvas
      ..drawRect(dolu, Paint()..color = renk)
      // Two flat tones read as a sticker; three read as a surface.
      ..drawRect(
        Rect.fromLTWH(dolu.left, dolu.top, dolu.width, dolu.height * .30),
        Paint()..color = const Color(0x59FFFFFF),
      )
      ..drawRect(
        Rect.fromLTWH(
          dolu.left,
          dolu.bottom - dolu.height * .22,
          dolu.width,
          dolu.height * .22,
        ),
        Paint()..color = const Color(0x33000000),
      )
      ..restore();
  }

  // --- glass, and the fog that is the same layer -----------------------
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        iz.left + h * .06,
        iz.top + h * .07,
        iz.width - h * .12,
        h * .13,
      ),
      Radius.circular(h * .07),
    ),
    Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: .05 + k * .16),
  );

  // --- frost, in front of the fill -------------------------------------
  if (k > 0) {
    final buz = Paint()
      ..color = const Color(0xFFDDF2FB).withValues(alpha: .55 + .35 * k);
    for (var i = 0; i < 7; i++) {
      final ux = iz.left + iz.width * _kiragiUst[i];
      final ub = kiragiBoyu(_kiragiUstBoy[i] * iz.height, k, iz.height);
      final ax = iz.left + iz.width * _kiragiAlt[i];
      final ab = kiragiBoyu(_kiragiAltBoy[i] * iz.height, k, iz.height);
      canvas
        ..drawPath(
          Path()
            ..moveTo(ux - h * .09, iz.top)
            ..lineTo(ux, iz.top + ub)
            ..lineTo(ux + h * .09, iz.top)
            ..close(),
          buz,
        )
        ..drawPath(
          Path()
            ..moveTo(ax - h * .09, iz.bottom)
            ..lineTo(ax, iz.bottom - ab)
            ..lineTo(ax + h * .09, iz.bottom)
            ..close(),
          buz,
        );
    }
  }

  // --- the badge -------------------------------------------------------
  // The dial's hub and its band glyph were two things; here they are one —
  // the only round object left, and the only place a name can go.
  final rozet = Offset(kasa.left + h * .30, kasa.center.dy - h * .06);
  final dCap = h * 1.25;
  final pop = durum.pop > 0
      ? Curves.easeOutBack.transform(1 - durum.pop / .4)
      : 1.0;
  canvas
    ..drawCircle(
      rozet + Offset(0, h * .09),
      dCap / 2,
      Paint()..color = TempoRenk.kontur,
    )
    ..drawCircle(rozet, dCap / 2, Paint()..color = TempoRenk.kontur)
    ..save()
    ..translate(rozet.dx, rozet.dy)
    ..scale(.35 + .65 * pop)
    ..rotate((1 - pop) * .5)
    ..translate(-rozet.dx, -rozet.dy)
    ..drawCircle(rozet, h * .48, Paint()..color = renk)
    ..drawCircle(
      rozet - Offset(0, h * .10),
      h * .34,
      Paint()..color = const Color(0x40FFFFFF),
    );
  drawGlyph(
    canvas,
    TempoRenk.glif[durum.bant]!,
    rozet,
    h * .52,
    TempoRenk.kontur,
  );
  canvas.restore();

  // --- the pulse and the number ----------------------------------------
  if (durum.halka > 0) {
    final can = (durum.halka / .45).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(durum.halkaX, iz.center.dy),
      h * .2 + h * .5 * (1 - can),
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .5 * can)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * .05,
    );
  }
  if (tempo.degisimKalan > 0) {
    final fade = (tempo.degisimKalan / 1.1).clamp(0.0, 1.0);
    final delta = tempo.sonDegisim;
    drawText(
      canvas,
      '${delta > 0 ? '+' : ''}${delta.round()}',
      Offset(
        durum.halkaX.clamp(iz.left, iz.right),
        kasa.top - h * .20 - (1 - fade) * h * .34,
      ),
      size: h * .40,
      weight: 900,
      family: 'Rubik',
      center: true,
      outline: TempoRenk.kontur,
      color: (delta > 0 ? TempoRenk.normal : TempoRenk.soguk).withValues(
        alpha: fade,
      ),
    );
  }
}
