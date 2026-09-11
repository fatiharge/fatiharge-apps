@Tags(['golden'])
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/presentation/render/customer_figure.dart';
import 'package:kiyma/presentation/render/figure.dart';
import 'package:kiyma/presentation/render/skewer.dart';
import 'package:kiyma/presentation/render/usta_acting.dart';
import 'package:kiyma/presentation/render/usta_figure.dart';

/// What the drawn parts of the scene cost to record, per frame.
///
/// Everything a picture used to do is now paths, and paths are not free: four
/// skewers drawn cost 112 us against 5 us for the sprite they replaced —
/// twenty times more. The question is whether that matters, and the answer is
/// the three numbers together against the budget:
///
///   4 skewers   112 us
///   the usta     74 us
///   3 customers  96 us
///   ----------------
///   total       282 us, which is 1.7 % of a 60 fps frame (16 667 us)
///
/// So it is affordable, and this test is here to keep it that way. The
/// ceiling is deliberately loose — five times the measured cost — because a
/// timing assertion tight enough to catch a 20 % regression would fail on a
/// busy machine. What it catches is the order-of-magnitude kind: a path
/// rebuilt per frame that used to be cached, a loop that grew a zero.
///
/// Tagged with the goldens and excluded from CI for the same reason they are:
/// the number belongs to the host that measured it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Microseconds to record [kere] frames of [f].
  double olc(String ad, int kere, void Function(Canvas) f) {
    for (var i = 0; i < 60; i++) {
      final r = PictureRecorder();
      f(Canvas(r));
      r.endRecording().dispose();
    }
    final saat = Stopwatch()..start();
    for (var i = 0; i < kere; i++) {
      final r = PictureRecorder();
      f(Canvas(r));
      r.endRecording().dispose();
    }
    saat.stop();
    return saat.elapsedMicroseconds / kere;
  }

  test('the drawn scene records inside a frame', () {
    final yuvalar = [
      for (var i = 0; i < 4; i++)
        Quad.fromRect(Rect.fromLTWH(6, 6 + i * 40.0, 220, 34)),
    ];

    final sis = olc('sis', 1000, (c) {
      for (var i = 0; i < 4; i++) {
        sisCiz(c, yuvalar[i], kizarma: .2 + i * .25, kavrulma: i * .3);
      }
    });
    // The costliest pose, not the cheapest: an arm raised past the chest is a
    // second group with its own two passes, and the bulb is eight more draws.
    final poz = UstaYonetmeni()
      ..olay(DayEvent.fikirDegisti)
      ..tick(.9);
    final usta = olc('usta', 1000, (c) => ustaCiz(c, poz.poz(1.4)));
    final musteri = olc('musteri', 1000, (c) {
      for (var i = 0; i < 3; i++) {
        musteriCiz(
          c,
          kokta: Offset(i * 168.0, 94),
          figur: figurAdlari[i],
          hal: CustomerMood.bekliyorStabil,
          palet: CustomerPalette.forSeed(.2 + i * .3, ak: false),
          t: 1.4,
          faz: i * 1.1,
        );
      }
    });

    expect(
      sis + usta + musteri,
      lessThan(1500),
      reason:
          'skewers $sis us, usta $usta us, customers $musteri us — something '
          'now costs an order of magnitude more than it did',
    );
  });
}
