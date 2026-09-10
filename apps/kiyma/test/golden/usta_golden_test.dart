@Tags(['golden'])
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/presentation/render/usta_figure.dart';

/// The usta alone, big, with the line the grill cuts him at.
///
/// He is 36 % of a scene the counter fills, so judging him from a crop of the
/// whole frame meant squinting at a corner and iterating blind. Everything
/// that matters about a face happens at a scale this sheet shows and that one
/// does not.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the usta, at four moments', (tester) async {
    // His figure sits at x 40…305, y 147…470 in scene space. Two up, drawn at
    // twice size, with the grill's waterline marked across each.
    const solX = 24.0;
    const hucreW = 300.0;
    const hucreH = 340.0;
    const olcek = 2.0;
    const anlar = [0.0, 1.4, 3.1, 5.7];
    const grillY = 360.0;

    late final Image sayfa;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawRect(
          const Rect.fromLTWH(0, 0, hucreW * 2 * olcek, hucreH * 2 * olcek),
          Paint()..color = const Color(0xFFEDE0C8),
        );
      for (var i = 0; i < anlar.length; i++) {
        final cx = (i % 2) * hucreW * olcek;
        final cy = (i ~/ 2) * hucreH * olcek;
        canvas
          ..save()
          ..clipRect(Rect.fromLTWH(cx, cy, hucreW * olcek, hucreH * olcek))
          ..translate(cx, cy)
          ..scale(olcek)
          ..translate(-solX, -105);
        ustaCiz(canvas, t: anlar[i]);
        // Where the grill's front edge crosses him: below this nothing of him
        // is ever seen, so nothing he does down there counts.
        canvas
          ..drawRect(
            const Rect.fromLTWH(solX, grillY, hucreW, 3),
            Paint()..color = const Color(0x66C0392B),
          )
          ..restore();
      }
      sayfa = await recorder.endRecording().toImage(
        (hucreW * 2 * olcek).round(),
        (hucreH * 2 * olcek).round(),
      );
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/usta.png'));
  });
}
