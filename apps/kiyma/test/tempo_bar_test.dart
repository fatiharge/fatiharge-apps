import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/presentation/render/tempo_bar.dart';

void main() {
  group('the band, with hysteresis', () {
    test('falling is immediate, rising has to be earned', () {
      // Down: the plain threshold, no waiting. A burnt skewer bites now.
      expect(Tempo.bantGecisi(24, TempoBand.normal), TempoBand.soguk);
      expect(Tempo.bantGecisi(54, TempoBand.isiniyor), TempoBand.normal);
      expect(Tempo.bantGecisi(79, TempoBand.ates), TempoBand.isiniyor);

      // Up: the value has to clear the boundary by the margin. Sitting on
      // 55 or 56 leaves the meter where it is; 58 earns the band.
      expect(Tempo.bantGecisi(56, TempoBand.normal), TempoBand.normal);
      expect(Tempo.bantGecisi(58, TempoBand.normal), TempoBand.isiniyor);
      expect(Tempo.bantGecisi(26, TempoBand.soguk), TempoBand.soguk);
      expect(Tempo.bantGecisi(28, TempoBand.soguk), TempoBand.normal);
      expect(Tempo.bantGecisi(82, TempoBand.isiniyor), TempoBand.isiniyor);
      expect(Tempo.bantGecisi(83, TempoBand.isiniyor), TempoBand.ates);
    });

    test('a fall drops as many bands as it needs to', () {
      // A burnt skewer and an angry customer inside a second is -28, and the
      // meter must not walk down one band at a time to follow it.
      expect(Tempo.bantGecisi(20, TempoBand.ates), TempoBand.soguk);
      expect(Tempo.bantGecisi(0, TempoBand.ates), TempoBand.soguk);
    });

    test('it never moves without the value moving', () {
      for (final bant in TempoBand.values) {
        for (var v = 0.0; v <= 100; v += 0.5) {
          final bir = Tempo.bantGecisi(v, bant);
          expect(
            Tempo.bantGecisi(v, bir),
            bir,
            reason: 'settling at $v from $bant must be stable',
          );
        }
      }
    });
  });

  group('the segments', () {
    test('a partial segment is the needle', () {
      expect(segmentDolulugu(0, 0), 0);
      expect(segmentDolulugu(5, 0), 0.5);
      expect(segmentDolulugu(10, 0), 1);
      expect(segmentDolulugu(10, 1), 0);
      expect(segmentDolulugu(55, 5), 0.5);
      expect(segmentDolulugu(55, 4), 1);
      expect(segmentDolulugu(55, 6), 0);
      for (var i = 0; i < 10; i++) {
        expect(segmentDolulugu(100, i), 1);
      }
    });
  });

  group('the frost', () {
    test('never closes the strip down the middle', () {
      // The spike lengths are constants above; this is the guard that stops
      // any of them, at any cold, from covering the level. A meter you
      // cannot read is a bug, not a mood.
      for (final taban in const [1.0, 10.0, 1000.0]) {
        expect(
          kiragiBoyu(taban, 1, 40),
          lessThanOrEqualTo(40 * kiragiTavani),
        );
      }
      expect(kiragiBoyu(20, 0, 40), 0);
      expect(kiragiBoyu(10, 0.5, 40), 5);
    });
  });
}
