@Tags(['golden'])
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/presentation/render/customer_figure.dart';
import 'package:kiyma/presentation/render/figure.dart';

/// Every silhouette in every mood, on one sheet.
///
/// The arms were rebuilt four times in a row and each fix looked right in the
/// head and wrong on screen: an elbow flaring past the body, a hand short of
/// the counter, a sleeve fused to the shirt so the arm read as a lump. None
/// of it was visible from the code — only from a render. This is that render,
/// kept in the repo so the next change to a limb has to face it.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every customer silhouette, in every mood', (tester) async {
    const hucreW = 102.4;
    // A fez tops out at -5 in seat space, so the cell needs headroom above
    // the figure's own origin or the hat comes off.
    const bosluk = 14.0;
    const hucreH = 164.0;
    const haller = CustomerMood.values;
    final w = hucreW * haller.length;
    final h = hucreH * figurAdlari.length;

    late final Image sayfa;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()..color = const Color(0xFFEDE0C8),
        );
      for (var r = 0; r < figurAdlari.length; r++) {
        for (var c = 0; c < haller.length; c++) {
          final kok = Offset(c * hucreW, r * hucreH + bosluk);
          canvas
            ..save()
            ..clipRect(Rect.fromLTWH(kok.dx, r * hucreH, hucreW, hucreH - 8));
          musteriCiz(
            canvas,
            kokta: kok,
            figur: figurAdlari[r],
            hal: haller[c],
            // A fixed seed: the sheet is a check on shape, and a palette that
            // rolled fresh every run would change the image without anything
            // changing.
            palet: CustomerPalette.forSeed(
              0.21 + r * 0.13,
              ak: figurler[figurAdlari[r]]!.ak,
            ),
            t: 0.4 + c * 0.7,
            faz: r * 1.1,
          );
          canvas.restore();
        }
        // The rail, so a hand that misses the counter is obvious.
        canvas.drawRect(
          Rect.fromLTWH(0, r * hucreH + hucreH - 8, w, 8),
          Paint()..color = const Color(0xFFC08A3E),
        );
      }
      sayfa = await recorder.endRecording().toImage(w.round(), h.round());
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/figures.png'));
  });
}
