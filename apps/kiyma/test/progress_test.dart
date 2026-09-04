import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';

void main() {
  group('Progress', () {
    test('spending never costs a level', () {
      final progress = Progress()..kazan(200);
      expect(progress.xp, 200);

      expect(progress.satinAl(const Unlock('malzeme_biber', 150)), isTrue);
      expect(progress.para, 50);
      expect(progress.xp, 200, reason: 'levels are not spent');
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
      expect(progress.xp, 70);
    });

    test('neither figure goes below zero', () {
      Progress().cezalandir(50);
      final progress = Progress()..cezalandir(50);
      expect(progress.para, 0);
      expect(progress.xp, 0);
    });

    test('the level threshold is the doc table', () {
      final progress = Progress();
      expect(progress.hedef, Balance.target(1));
      expect(progress.seviyeAtlandi, isFalse);
      progress.kazan(Balance.target(1));
      expect(progress.seviyeAtlandi, isTrue);
    });

    test('levelling consumes as many thresholds as the xp covers', () {
      final progress = Progress()..kazan(Balance.target(3));
      expect(progress.seviyeleriIsle(), 3);
      expect(progress.gun, 4);
      expect(progress.seviyeleriIsle(), 0, reason: 'nothing left to take');
    });

    test('the counter only shows what has been bought', () {
      final unlocks = Unlocks();
      expect(unlocks.shows('malzeme_domates'), isTrue);
      for (final region in [
        'malzeme_biber',
        'malzeme_ezme',
        'tatli_baklava',
        'surahi_ayran',
        'kola_kaynak',
        'tabak_kaynak',
        'tabak_hazirlama',
        'bardak_kaynak',
        'bardak_bekletme',
        'musteri_slot_3',
        'musteri_slot_4',
      ]) {
        expect(unlocks.shows(region), isFalse, reason: region);
      }

      // A drink is not on the counter until the line it pours into is.
      unlocks.open('icecek_ayran');
      expect(unlocks.shows('surahi_ayran'), isFalse);
      unlocks.open('icecek_hatti');
      expect(unlocks.shows('surahi_ayran'), isTrue);
      expect(unlocks.shows('bardak_bekletme'), isTrue);

      unlocks
        ..open('musteri_3')
        ..open('musteri_4');
      expect(unlocks.shows('musteri_slot_4'), isTrue);
    });

    test('the bar is drawn between levels, not from zero', () {
      final progress = Progress()
        ..kazan(Balance.target(1))
        ..seviyeleriIsle();
      expect(progress.seviyeTabani, Balance.target(1));
      expect(progress.seviyeOrani, 0);
    });
  });
}
