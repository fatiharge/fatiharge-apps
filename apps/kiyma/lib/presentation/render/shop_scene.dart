import 'dart:ui';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart' show CustomPainter;
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/render/grill.dart';
import 'package:kiyma/presentation/render/painter.dart';
import 'package:kiyma/presentation/render/skewer.dart';
import 'package:kiyma/presentation/render/tag_layout.dart';

/// The kitchen, drawn with nothing happening in it.
///
/// It does not share the counter's own drawing passes on purpose. The counter
/// draws a running game — a chef, four grill dials, whatever is in the hand —
/// and hides everything money has not opened; the shop draws a still room and
/// its whole job is to show exactly what the counter hides. One function with
/// hooks for both would be a function nobody could read, and neither of these
/// is more than a loop.
class ShopScenePainter extends CustomPainter {
  const ShopScenePainter({
    required this.scene,
    required this.assets,
    required this.unlocks,
    required this.etiketler,
    this.secili,
  });

  final SceneData scene;
  final GameAssets assets;
  final Unlocks unlocks;

  /// What is for sale where, and for how much. One tag per object: a
  /// ladder only ever offers its next rung, and two prices hanging off the
  /// same jug would be a menu.
  final Map<String, int> etiketler;

  /// The region whose card is open, drawn lit.
  final String? secili;

  /// What a locked area looks like here: its own art, faint, inside a dashed
  /// outline. Not a padlock — the point is that the player sees the thing
  /// they would be buying standing in the place it would stand.
  static const _hayalet = 0.32;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / scene.size.width, size.height / scene.size.height);

    for (final layer in scene.layers) {
      // The grill is drawn, here as in the kitchen. This screen used to blit
      // the painted one the counter stopped using, so a player walked out of
      // a kitchen with a steel trough and four lit slots into a shop showing
      // a different grill with a painted raw skewer lying across it — on the
      // screen that is asking them to pay for a fourth slot on it.
      if (layer.name == 'mangal_katman') {
        if (scene.maybe('mangal_alani') case final mangal?) {
          mangalCiz(canvas, mangal.quad, t: 0, isi: .55);
        }
        continue;
      }
      final image = assets[layer.src];
      if (image == null) continue;
      drawInQuad(
        canvas,
        image,
        Quad.fromRect(layer.rect),
        AssetFit.doldur,
      );
    }

    for (final region in scene.regions) {
      if (region.category == 'dekor') continue;
      final acik = unlocks.shows(region.name);
      // The slots, drawn the way the kitchen draws them: one skewer per slot
      // the player owns, a dashed outline on the ones they do not. The region
      // used to blit a single raw-skewer picture across the whole trough,
      // which showed one skewer on a four-slot grill and said nothing about
      // which of the four were for sale.
      if (region.name == 'mangal_alani') {
        final yuvalar = region.slots;
        for (var i = 0; i < yuvalar.length; i++) {
          if (i < unlocks.mangalSlots) {
            sisCiz(
              canvas,
              Quad(
                yuvalar[i].bottomLeft,
                yuvalar[i].topLeft,
                yuvalar[i].topRight,
                yuvalar[i].bottomRight,
              ),
              kizarma: .25 + i * .25,
              kavrulma: 0,
            );
          } else {
            _kesikli(
              canvas,
              yuvalar[i],
              renk: const Color(0xCCF7EEDF),
            );
          }
        }
        continue;
      }
      final asset = region.asset;
      final image = asset == null ? null : assets[asset];
      if (image == null) {
        // A place at the counter has no art of its own — the person standing
        // in it is the art — so the shop draws a body, or the third place
        // would be a price on a string pointing at bare tiles.
        if (!acik && region.category == 'musteri') {
          _yerHayaleti(canvas, region.quad);
        } else if (etiketler.containsKey(region.name)) {
          // A shelf or a prep board has no art of its own, so a tag over one
          // points at bare steel. The outline is what the tag is pointing at.
          _kesikli(canvas, region.quad);
        }
        continue;
      }
      if (!acik) _zemin(canvas, region.quad);
      drawInQuad(
        canvas,
        image,
        region.quad,
        region.fit,
        paint: acik
            ? null
            : (Paint()
                ..color = const Color(0xFFFFFFFF).withValues(alpha: _hayalet)),
      );
      if (!acik) _kesikli(canvas, region.quad);
    }

    _etiketleriCiz(canvas);

    canvas.restore();
  }

  /// Every tag, moved up out of each other's way.
  ///
  /// Two ladders can be live on neighbouring objects — the ayran jug and the
  /// şalgam jug sit 46 units apart and a tag is about fifty wide — so the
  void _etiketleriCiz(Canvas canvas) {
    for (final tag in TagLayout.of(scene, etiketler).tags) {
      final region = scene.maybe(tag.region);
      if (region != null) _etiket(canvas, region, tag.price, tag.rect);
    }
  }

  /// A price on a string, hung off the top of the thing it is for.
  ///
  /// Above rather than over: the whole point of buying at the object is
  /// seeing the object, and a tag across the middle of an empty steel well
  /// hides the one thing that explains what the well is.
  void _etiket(Canvas canvas, SceneRegion region, int fiyat, Rect rect) {
    final lit = secili == region.name;
    final tag = assets['fiyat_etiketi'];
    if (tag == null) {
      drawKey(
        canvas,
        rect.deflate(rect.height * 0.28),
        const Color(0xFFF7EEDF),
      );
    } else {
      drawCentered(
        canvas,
        tag,
        rect.center,
        rect.width,
        paint: lit
            ? (Paint()
                ..colorFilter = const ColorFilter.mode(
                  Color(0xFFE8641A),
                  BlendMode.modulate,
                ))
            : null,
      );
    }
    drawText(
      canvas,
      goldText(fiyat),
      // Into the paper, which is the lower two thirds of the art — above it
      // is the string the tag hangs by.
      rect.center + Offset(0, rect.height * 0.14),
      size: 12,
      weight: 900,
      family: 'Rubik',
      center: true,
      middle: true,
      color: const Color(0xFF2E2A26),
    );
  }

  /// A pale wash behind a thing that is not there yet.
  ///
  /// The faint art on its own was not enough: a dimmed tray of pickles still
  /// reads as a tray of pickles. Sitting it on a cream card says the well is
  /// empty and this is what would fill it.
  void _zemin(Canvas canvas, Quad quad) => canvas.drawRRect(
    RRect.fromRectAndRadius(
      quad.bounds.inflate(3),
      const Radius.circular(7),
    ),
    Paint()..color = const Color(0xFFF7EEDF).withValues(alpha: 0.72),
  );

  /// The body a customer would be, for a place nobody has bought yet.
  void _yerHayaleti(Canvas canvas, Quad quad) {
    final bounds = quad.bounds;
    final paint = Paint()
      ..color = const Color(0xFF6FCF7C).withValues(alpha: 0.3);
    canvas
      ..drawCircle(Offset(bounds.center.dx, bounds.top + 26), 19, paint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bounds.left + 14,
            bounds.top + 46,
            bounds.width - 28,
            46,
          ),
          const Radius.circular(14),
        ),
        paint,
      );
    _kesikli(canvas, quad);
  }

  /// A dashed outline round something that is not there yet. Drawn by hand
  /// because a dash pattern is four lines of arithmetic and the alternative
  /// is a package.
  /// [renk] is for the one place the ink line has nothing to sit on: the
  /// grill's own slots are dashed onto a bed of coals, and dark ink at half
  /// alpha over dark coals is nothing at all.
  void _kesikli(Canvas canvas, Quad quad, {Color? renk}) {
    final paint = Paint()
      ..color = renk ?? const Color(0xFF2E2A26).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final corners = quad.corners;
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      final length = (b - a).distance;
      const dash = 7.0;
      for (var t = 0.0; t < length; t += dash * 2) {
        final from = Offset.lerp(a, b, t / length)!;
        final to = Offset.lerp(a, b, (t + dash).clamp(0, length) / length)!;
        canvas.drawLine(from, to, paint);
      }
    }
  }

  @override
  /// [Unlocks] is mutated in place and has no equality, so comparing the two
  /// instances always answers "same" — a purchase would leave the old price
  /// hanging off the thing it just bought. The tags are what actually
  /// changed, so the tags are what is compared.
  bool shouldRepaint(ShopScenePainter old) =>
      old.secili != secili ||
      !mapEquals(old.etiketler, etiketler) ||
      old.unlocks.opened.length != unlocks.opened.length;
}
