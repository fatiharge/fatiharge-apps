import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/presentation/render/figure.dart' show cx;
import 'package:kiyma/presentation/render/usta_acting.dart';
import 'package:kiyma/presentation/render/usta_figure.dart';

/// Where the grill's rim crosses him. Below it he is behind steel, and a
/// gesture down there is work nobody in the game will ever see.
const _suHatti = 430.0;

/// Drives a fresh director into [isi] and returns it, or fails saying so.
UstaYonetmeni _surukle(UstaIsi isi, {bool bosTezgah = false}) {
  final yonetmen = UstaYonetmeni(random: _Hileli(isi));
  for (final girdi in _tetikler.entries) {
    if (girdi.value == isi) {
      yonetmen.olay(girdi.key);
      return yonetmen;
    }
  }
  for (var i = 0; i < 2000 && yonetmen.isi != isi; i++) {
    yonetmen.tick(1 / 60, bosTezgah: bosTezgah);
  }
  expect(yonetmen.isi, isi, reason: 'could not get him to $isi');
  return yonetmen;
}

const _tetikler = <DayEvent, UstaIsi>{
  DayEvent.musteriKizgin: UstaIsi.kiz,
  DayEvent.gunlukHedef: UstaIsi.sevin,
  DayEvent.bahsis: UstaIsi.keseyeBak,
  DayEvent.fikirDegisti: UstaIsi.fikir,
};

void main() {
  group('every gesture lands somewhere it can be seen', () {
    // Three rules, all of them learned the hard way, and all three invisible
    // in the code of a beat: the arm cannot reach his own forehead, the apron
    // is painted over his hands, and the grill cuts him off at the rim.
    for (final isi in UstaIsi.values) {
      if (isi == UstaIsi.bekle || isi == UstaIsi.konus) continue;
      test('$isi', () {
        final yonetmen = _surukle(isi, bosTezgah: isi == UstaIsi.esne);
        for (var kare = 0; kare < 200; kare++) {
          final p = yonetmen.poz(kare / 60);
          for (final (yon, el) in [(-1.0, p.solEl), (1.0, p.sagEl)]) {
            final omuz = ustaOmuz(yon);
            expect(
              (el - omuz).distance,
              lessThanOrEqualTo(ustaKolBoyu + .5),
              reason:
                  '$isi reaches past the arm it has; the rig would pull it '
                  'back and the gesture would stop short of where it means',
            );
            expect(
              el.dy,
              lessThan(_suHatti),
              reason: '$isi puts a hand under the grill, where nothing shows',
            );
            // Raised is allowed anywhere — that arm is painted in front of
            // everything. Otherwise it has to clear the apron, which is
            // painted over it.
            expect(
              el.dy < ustaKaldirikEsigi ||
                  (el.dx - cx).abs() > ustaOnlukYari(el.dy),
              isTrue,
              reason: '$isi hides a hand behind the apron at $el',
            );
          }
        }
        yonetmen.tick(1 / 60);
      });
    }
  });

  group('what he notices', () {
    test('the counter chatter moves nothing', () {
      // Measured per busy run: 114 accepted items, 65 arrivals, 66 tempo
      // overflows, 62 happy customers. A face on any of them is a tic.
      for (final olay in const [
        DayEvent.kabul,
        DayEvent.musteriGeldi,
        DayEvent.musteriMemnun,
        DayEvent.tempoBonusu,
        DayEvent.gecersiz,
        DayEvent.gunBitti,
      ]) {
        final yonetmen = UstaYonetmeni(random: _Hileli(UstaIsi.sisCevir))
          ..olay(olay);
        expect(yonetmen.isi, UstaIsi.bekle, reason: '$olay moved him');
      }
    });

    test('bad news interrupts good, and good does not interrupt bad', () {
      final a = UstaYonetmeni(random: _Hileli(UstaIsi.sisCevir))
        ..olay(DayEvent.gunlukHedef)
        ..olay(DayEvent.musteriKizgin);
      expect(a.isi, UstaIsi.kiz);

      final b = UstaYonetmeni(random: _Hileli(UstaIsi.sisCevir))
        ..olay(DayEvent.musteriKizgin)
        ..olay(DayEvent.gunlukHedef);
      expect(b.isi, UstaIsi.kiz);
    });

    test('a chore never starts on top of a reaction', () {
      final yonetmen = UstaYonetmeni(random: _Hileli(UstaIsi.sisCevir))
        ..olay(DayEvent.musteriKizgin);
      for (var i = 0; i < 60; i++) {
        yonetmen.tick(1 / 60);
        expect(yonetmen.isi, UstaIsi.kiz);
      }
    });

    test('a lesson keeps his mouth going, and lets go of it after', () {
      final yonetmen = UstaYonetmeni(random: _Hileli(UstaIsi.sisCevir))
        ..konusma(acik: true);
      expect(yonetmen.isi, UstaIsi.konus);
      // It has no length of its own: five seconds in, he is still talking.
      for (var i = 0; i < 300; i++) {
        yonetmen.tick(1 / 60);
      }
      expect(yonetmen.isi, UstaIsi.konus);
      // And the mouth actually moves, rather than resting open. Ticked
      // between samples: the beat runs off the director's own clock, so a
      // pose asked for twice without a tick between is the same pose twice.
      final acikliklar = <double>[];
      for (var i = 0; i < 40; i++) {
        acikliklar.add(yonetmen.poz(i / 60).agiz);
        for (var k = 0; k < 5; k++) {
          yonetmen.tick(1 / 60);
        }
      }
      expect(
        acikliklar.reduce(math.max) - acikliklar.reduce(math.min),
        greaterThan(6),
      );

      yonetmen.konusma(acik: false);
      expect(yonetmen.isi, UstaIsi.bekle);
    });

    test('he only yawns when there is nothing on', () {
      final mesgul = UstaYonetmeni(random: _Hileli(UstaIsi.esne));
      for (var i = 0; i < 3000; i++) {
        mesgul.tick(1 / 60);
        expect(mesgul.isi, isNot(UstaIsi.esne));
      }
    });
  });
}

/// A die that always rolls the chore a test is about.
class _Hileli implements math.Random {
  _Hileli(this.istenen);

  final UstaIsi istenen;

  /// Mirrors the pools in `usta_acting.dart`, yawn included: a chore added
  /// there and not here shows up as a test that cannot reach its own beat.
  static const _liste = <UstaIsi>[
    UstaIsi.sisCevir,
    UstaIsi.sisCevir,
    UstaIsi.biyikBur,
    UstaIsi.alinSil,
    UstaIsi.etrafaBak,
    UstaIsi.esne,
    UstaIsi.etrafaBak,
  ];

  @override
  int nextInt(int max) {
    final i = _liste.indexOf(istenen);
    return i < 0 ? 0 : i % max;
  }

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}
