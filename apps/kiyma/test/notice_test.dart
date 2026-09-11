import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/presentation/render/notice.dart';

/// Where a badge lands, which is the whole of what the player experiences of
/// it. The words come from the translation file and the colour from one
/// table; everything that can go wrong is arithmetic about position.
void main() {
  const sahne = Size(1024, 576);

  group('where a notice stands', () {
    test('news about somebody at the counter hangs under them', () {
      // The top of the frame is the order tickets and the faces under them.
      expect(bildirimAsili(const Offset(380, 158), sahne), isTrue);
      final kasa = bildirimKutusu(
        const Offset(380, 158),
        180,
        sahne,
        asili: true,
      );
      expect(kasa.top, greaterThan(158));
    });

    test('news about the grill stands on top of it', () {
      expect(bildirimAsili(const Offset(157, 460), sahne), isFalse);
      final kasa = bildirimKutusu(
        const Offset(157, 460),
        180,
        sahne,
        asili: false,
      );
      expect(kasa.bottom, lessThan(460));
    });

    test('a badge at the edge of the room is pushed back into it', () {
      // The grill and the purse are both against a wall of the frame, and
      // half a warning is not a warning.
      for (final at in const [
        Offset(20, 500),
        Offset(1010, 500),
        Offset(20, 8),
        Offset(1010, 570),
      ]) {
        final kasa = bildirimKutusu(
          at,
          220,
          sahne,
          asili: bildirimAsili(at, sahne),
        );
        expect(kasa.left, greaterThanOrEqualTo(0));
        expect(kasa.right, lessThanOrEqualTo(sahne.width));
        expect(kasa.top, greaterThanOrEqualTo(0));
        expect(kasa.bottom, lessThanOrEqualTo(sahne.height));
      }
    });
  });

  group('when two of them arrive at once', () {
    const kasa = Rect.fromLTWH(300, 200, 180, 30);

    test('the second stands clear of the first', () {
      final kayma = bildirimKaymasi(kasa, [kasa], asili: false);
      expect(kayma, greaterThanOrEqualTo(kasa.height));
      expect(kasa.shift(Offset(0, -kayma)).overlaps(kasa), isFalse);
    });

    test('it moves away from what it is about, not across it', () {
      // A hung badge that stepped upward would climb back over the face it
      // belongs to.
      expect(
        kasa.shift(Offset(0, bildirimKaymasi(kasa, [kasa], asili: true))).top,
        greaterThan(kasa.top),
      );
    });

    test('it keeps off the money and the meter', () {
      const para = Rect.fromLTWH(290, 190, 100, 53);
      final kayma = bildirimKaymasi(kasa, const [para], asili: false);
      expect(kasa.shift(Offset(0, -kayma)).overlaps(para), isFalse);
    });

    test('four deep it gives up rather than hiding the room', () {
      final her = [
        for (var i = 0; i < 9; i++) kasa.shift(Offset(0, -i * 36.0)),
      ];
      expect(
        bildirimKaymasi(kasa, her, asili: false),
        4 * (kasa.height + 6),
      );
    });
  });

  group('what is worth saying out loud', () {
    test(
      'the first two mis-moves in a row are answered by the flash alone',
      () {
        final tempo = Tempo();
        for (var i = 0; i < Tempo.bagislanan; i++) {
          tempo.gecersizHareket();
          expect(tempo.affedilmez, isFalse);
        }
        tempo.gecersizHareket();
        expect(tempo.affedilmez, isTrue);
      },
    );

    test('a move that lands clears the run', () {
      final tempo = Tempo();
      for (var i = 0; i < 4; i++) {
        tempo.gecersizHareket();
      }
      expect(tempo.affedilmez, isTrue);
      tempo.basarili();
      expect(tempo.affedilmez, isFalse);
    });
  });
}
