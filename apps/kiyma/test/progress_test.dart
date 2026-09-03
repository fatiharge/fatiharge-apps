import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';

void main() {
  group('Progress', () {
    test('spending never pushes the day target backwards', () {
      final progress = Progress()..kazan(200);
      expect(progress.toplamKazanc, 200);

      expect(progress.satinAl(const Unlock('malzeme_biber', 150)), isTrue);
      expect(progress.para, 50);
      expect(progress.toplamKazanc, 200, reason: 'the target is cumulative');
      expect(progress.unlocks.has('malzeme_biber'), isTrue);
    });

    test('will not sell what there is no money for', () {
      final progress = Progress()..kazan(10);
      expect(progress.satinAl(const Unlock('malzeme_biber', 150)), isFalse);
      expect(progress.para, 10);
    });

    test('a burn slows the target as well as the till', () {
      final progress = Progress()
        ..kazan(100)
        ..cezalandir(30);
      expect(progress.para, 70);
      expect(progress.toplamKazanc, 70);
    });

    test('neither figure goes below zero', () {
      Progress().cezalandir(50);
      final progress = Progress()..cezalandir(50);
      expect(progress.para, 0);
      expect(progress.toplamKazanc, 0);
    });

    test('the day target is the doc table', () {
      final progress = Progress();
      expect(progress.hedef, Balance.target(1));
      expect(progress.hedefTutturuldu, isFalse);
      progress.kazan(Balance.target(1));
      expect(progress.hedefTutturuldu, isTrue);
    });
  });
}
