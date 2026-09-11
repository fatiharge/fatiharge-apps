import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/presentation/render/figure.dart';

void main() {
  group('the customers', () {
    test('every name in the roll call has a body to go with it', () {
      // The name list is what the counter picks from, and the miss would be
      // a crash on whichever day that customer first turned up. The sheet
      // golden would catch it, but goldens do not run in CI.
      expect(
        figurAdlari.where((ad) => !figurler.containsKey(ad)),
        isEmpty,
        reason: 'these are drawn from but have no FigureSpec',
      );
      expect(
        figurler.keys.where((ad) => !figurAdlari.contains(ad)),
        isEmpty,
        reason: 'these are built but never turn up at the counter',
      );
    });

    test('everybody can reach the counter', () {
      for (final ad in figurAdlari) {
        final f = figurler[ad]!;
        // The hand hangs to the rail. Shorter and it floats over the counter,
        // longer and it disappears under it — and the arm is measured off
        // this, so a body whose shoulders sit wrong breaks the whole limb.
        final el = f.omuzY + 10 + f.kolBoyu;
        expect(el, greaterThan(ray - 6), reason: '$ad cannot reach the rail');
        expect(el, lessThan(kesim), reason: "$ad's hand is under the counter");
      }
    });

    test('nobody grows through the ceiling', () {
      for (final ad in figurAdlari) {
        expect(figurler[ad]!.tepe, greaterThan(-14), reason: '$ad is too tall');
      }
    });

    test('every shape asks for a colour the palette knows', () {
      const roller = {
        'ten',
        'tenGolge',
        'burunR',
        'govde',
        'govdeG',
        'govdeK',
        'yelek',
        'yelekG',
        'sac',
        'sacG',
        'sapkaR',
        'sapkaG',
        'sapkaK',
        'dudak',
        'altin',
        'altinG',
        'biyikR',
      };
      for (final ad in figurAdlari) {
        final p = FigureParts.of(ad);
        for (final s in [...p.govde, ...p.kafa]) {
          expect(roller, contains(s.rol), reason: '$ad asks for ${s.rol}');
        }
      }
    });
  });
}
