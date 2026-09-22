@Tags(['golden'])
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/presentation/render/usta_acting.dart';
import 'package:kiyma/presentation/render/usta_figure.dart';

/// His whole repertoire, each beat caught at its peak.
///
/// Two rows per beat because the peak is not the whole of it — a gesture that
/// looks right at its crest and wrong on the way in is a gesture that is
/// wrong. Each cell is labelled and the grill's waterline is drawn across it:
/// a hand below that line is a hand nobody in the game will ever see.
///
/// Excluded from CI with the other goldens: the baseline is drawn by the
/// host, so a macOS image does not match a Linux one.
///
/// Rewrite it with `melos run test:golden -- --update-goldens`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Without it the labels come out as the test font's black boxes, and a
    // contact sheet you cannot read the captions on is twenty faces in a row.
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
  });

  testWidgets('everything the usta does', (tester) async {
    // Where the grill's rim crosses him, in scene coordinates. Below it he is
    // behind steel.
    const suHatti = 430.0;
    const solX = 30.0;
    // High enough to take in the bulb, which stands above his head.
    const ustX = 84.0;
    const hucreW = 290.0;
    const hucreH = 364.0;
    const olcek = 1.0;
    const sutun = 5;

    // One event apiece for the reactions; the chores are started directly.
    const sahneler = <(String, UstaIsi, DayEvent?)>[
      ('bekle', UstaIsi.bekle, null),
      ('sis cevir', UstaIsi.sisCevir, null),
      ('biyik bur', UstaIsi.biyikBur, null),
      ('alin sil', UstaIsi.alinSil, null),
      ('etrafa bak', UstaIsi.etrafaBak, null),
      ('esne', UstaIsi.esne, null),
      ('sevin', UstaIsi.sevin, DayEvent.gunlukHedef),
      ('kiz', UstaIsi.kiz, DayEvent.musteriKizgin),
      ('keseye bak', UstaIsi.keseyeBak, DayEvent.bahsis),
      ('fikir', UstaIsi.fikir, DayEvent.fikirDegisti),
    ];
    // Two moments through each: on the way up, and at the crest.
    const anlar = [.28, .5];

    late final Image sayfa;
    await tester.runAsync(() async {
      final satir = (sahneler.length * anlar.length + sutun - 1) ~/ sutun;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawRect(
          Rect.fromLTWH(0, 0, sutun * hucreW * olcek, satir * hucreH * olcek),
          Paint()..color = const Color(0xFFEDE0C8),
        );
      var hucre = 0;
      for (final (ad, isi, olay) in sahneler) {
        for (final an in anlar) {
          final cx = (hucre % sutun) * hucreW * olcek;
          final cy = (hucre ~/ sutun) * hucreH * olcek;
          hucre++;

          // Driven the way the game drives it: an event in, or a chore rolled
          // out of a seeded director, then ticked to the moment wanted.
          final yonetmen = UstaYonetmeni(random: _Sabit(isi));
          if (olay != null) {
            yonetmen.olay(olay);
          } else if (isi != UstaIsi.bekle) {
            // No public way to start a chore, and there should not be: the
            // clock is what starts them. Run it forward until it does.
            for (var i = 0; i < 600 && yonetmen.isi == UstaIsi.bekle; i++) {
              yonetmen.tick(1 / 60, bosTezgah: isi == UstaIsi.esne);
            }
          }
          final boyu = yonetmen.isi == UstaIsi.bekle ? 1.0 : _boy[isi]!;
          for (var i = 0; i < (boyu * an * 60).round(); i++) {
            yonetmen.tick(1 / 60, bosTezgah: isi == UstaIsi.esne);
          }

          canvas
            ..save()
            ..clipRect(Rect.fromLTWH(cx, cy, hucreW * olcek, hucreH * olcek))
            ..translate(cx, cy)
            ..scale(olcek)
            ..translate(-solX, -ustX);
          ustaCiz(canvas, yonetmen.poz(3.1));
          canvas
            ..drawRect(
              const Rect.fromLTWH(solX, suHatti, hucreW, 3),
              Paint()..color = const Color(0x66C0392B),
            )
            ..restore();
          _yaz(canvas, '$ad ${(an * 100).round()}%', Offset(cx + 8, cy + 6));
        }
      }
      sayfa = await recorder.endRecording().toImage(
        (sutun * hucreW * olcek).toInt(),
        (satir * hucreH * olcek).toInt(),
      );
    });

    await expectLater(sayfa, matchesGoldenFile('goldens/usta_acting.png'));
  });
}

/// Beat lengths, mirrored here so the sheet can land on a fraction of one.
const _boy = <UstaIsi, double>{
  UstaIsi.sisCevir: 2.2,
  UstaIsi.biyikBur: 1.9,
  UstaIsi.alinSil: 1.5,
  UstaIsi.etrafaBak: 1.7,
  UstaIsi.esne: 2.0,
  UstaIsi.sevin: 1.15,
  UstaIsi.kiz: 1.35,
  UstaIsi.keseyeBak: 1.0,
  UstaIsi.fikir: 1.8,
};

/// A die that always rolls the chore this cell is about.
class _Sabit implements math.Random {
  _Sabit(this.istenen);

  final UstaIsi istenen;

  /// Mirrors the two pools in `usta_acting.dart`. They are private there for
  /// a good reason and this is the price of it: a chore added there and not
  /// here comes out of this sheet as the wrong cell, which is visible.
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

void _yaz(Canvas canvas, String metin, Offset at) {
  (TextPainter(
    text: TextSpan(
      text: metin,
      style: const TextStyle(
        fontSize: 13,
        fontFamily: 'Rubik',
        color: Color(0xFF6A5B48),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout()).paint(canvas, at);
}
