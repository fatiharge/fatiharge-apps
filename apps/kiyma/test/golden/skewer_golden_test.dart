@Tags(['golden'])
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/presentation/render/skewer.dart';

/// One skewer across the whole cook, in two rows.
///
/// The four painted states could only ever be checked one at a time. What
/// matters about a drawn one is the run between them — that raw reads as raw,
/// that ready is unmistakable, and that the darkening before it burns is
/// visible early enough to act on. That is a strip, not a frame.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a skewer, from raw to gone', (tester) async {
    const hucreW = 300.0;
    const hucreH = 62.0;
    // Row one is the cook; row two is the window running out after it.
    const pisme = [0.0, .18, .36, .54, .72, .88, 1.0];
    const kavrulma = [0.0, .18, .36, .54, .72, .88, 1.0];

    late final Image sayfa;
    await tester.runAsync(() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawRect(
          const Rect.fromLTWH(0, 0, hucreW, hucreH * 14),
          Paint()..color = const Color(0xFF2A1F18),
        );
      for (var i = 0; i < pisme.length; i++) {
        sisCiz(
          canvas,
          Quad.fromRect(Rect.fromLTWH(6, i * hucreH + 6, hucreW - 12, 50)),
          kizarma: pisme[i],
          kavrulma: 0,
        );
      }
      for (var i = 0; i < kavrulma.length; i++) {
        sisCiz(
          canvas,
          Quad.fromRect(
            Rect.fromLTWH(6, (pisme.length + i) * hucreH + 6, hucreW - 12, 50),
          ),
          kizarma: 1,
          kavrulma: kavrulma[i],
        );
      }
      sayfa = await recorder.endRecording().toImage(
        hucreW.round(),
        (hucreH * 14).round(),
      );
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/skewer.png'));
  });
}
