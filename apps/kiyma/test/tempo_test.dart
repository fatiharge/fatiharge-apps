import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/tempo.dart';

void main() {
  group('Tempo', () {
    test('opens halfway, where every multiplier is neutral', () {
      final tempo = Tempo();
      expect(tempo.deger, Tempo.baslangic);
      expect(tempo.hal, TempoHali.normal);
      expect(tempo.paraCarpani, 1);
      expect(tempo.pismeCarpani, 1);
      expect(tempo.sabirCarpani, 1);
    });

    test('drains on its own, and faster the longer nobody is served', () {
      final slow = Tempo()..tick(1, bekleyen: true);
      final fast = Tempo();
      for (var i = 0; i < 30; i++) {
        fast.tick(1, bekleyen: true);
      }
      final earlyLoss = Tempo.baslangic - slow.deger;
      final lateLoss = (Tempo.baslangic - fast.deger) / 30;
      expect(lateLoss, greaterThan(earlyLoss));
      expect(earlyLoss, closeTo(Tempo.sizma, 0.01));
    });

    test('serving pays more the calmer they still were', () {
      final rushed = Tempo()..servisEdildi(tamami: true, sabirOrani: 0);
      final prompt = Tempo()..servisEdildi(tamami: true, sabirOrani: 1);
      expect(rushed.deger, greaterThan(Tempo.baslangic));
      expect(prompt.deger, greaterThan(rushed.deger));
    });

    test('the last stretch of the meter is the hardest to earn', () {
      final cold = Tempo();
      for (var i = 0; i < 20; i++) {
        cold.musteriKizdi();
      }
      final fromCold = cold.deger;
      cold.servisEdildi(tamami: true, sabirOrani: 1);
      final cheap = cold.deger - fromCold;

      final warm = Tempo();
      for (var i = 0; i < 6; i++) {
        warm.servisEdildi(tamami: true, sabirOrani: 1);
      }
      final fromWarm = warm.deger;
      warm.servisEdildi(tamami: true, sabirOrani: 1);

      expect(warm.deger - fromWarm, lessThan(cheap / 2));
    });

    test('the first two mis-moves are cheap and the third is not', () {
      final tempo = Tempo()
        ..gecersizHareket()
        ..gecersizHareket();
      // Forgiveness is about the punishment, not about pretending nothing
      // happened: every wrong move moves the needle.
      expect(
        tempo.deger,
        closeTo(Tempo.baslangic + Tempo.hataDokunusu * 2, 0.001),
        reason: 'a slipping finger, but not a free one',
      );

      final before = tempo.deger;
      tempo.gecersizHareket();
      expect(tempo.deger, closeTo(before + Tempo.hataBirim, 0.001));

      final third = tempo.deger;
      tempo.gecersizHareket();
      expect(
        third - tempo.deger,
        greaterThan(-Tempo.hataBirim),
        reason: 'and it costs more each time after that',
      );
    });

    test('anything that works resets the run of mis-moves', () {
      final punished = Tempo();
      for (var i = 0; i < 5; i++) {
        punished.gecersizHareket();
      }

      final forgiven = Tempo();
      for (var i = 0; i < 5; i++) {
        forgiven.gecersizHareket();
        if (i == 1) forgiven.basarili();
      }

      // Same five mis-moves; the one that got a move right in the middle of
      // them never reaches the graded penalty.
      expect(forgiven.deger, greaterThan(punished.deger));
    });

    test('every accepted move is worth something on its own', () {
      final tempo = Tempo();
      final before = tempo.deger;
      tempo.basarili();
      expect(tempo.deger, greaterThan(before));
      // Quiet: a floating number on every touch is noise, so only the
      // needle and the hub report it.
      expect(tempo.degisimKalan, 0);
      expect(tempo.dokunusKalan, greaterThan(0));
      expect(tempo.sonDokunusIyi, isTrue);

      tempo.gecersizHareket();
      expect(tempo.sonDokunusIyi, isFalse);
    });

    test('it cannot leave the meter', () {
      final cold = Tempo();
      for (var i = 0; i < 20; i++) {
        cold.musteriKizdi();
      }
      expect(cold.deger, 0);
      expect(cold.hal, TempoHali.soguk);

      final hot = Tempo();
      for (var i = 0; i < 20; i++) {
        hot.servisEdildi(tamami: true, sabirOrani: 1);
      }
      expect(hot.deger, 100);
      expect(hot.hal, TempoHali.ates);
    });

    test('a cold counter pays half and is barely harder', () {
      final cold = Tempo();
      for (var i = 0; i < 20; i++) {
        cold.musteriKizdi();
      }
      expect(cold.paraCarpani, 0.5, reason: 'the punishment is the money');
      expect(
        cold.pismeCarpani,
        1,
        reason: 'the cooked window never narrows: that way lies a spiral',
      );
      expect(cold.sabirCarpani, closeTo(0.9, 0.001));
    });

    test('a hot counter pays half again and buys room', () {
      final hot = Tempo();
      for (var i = 0; i < 20; i++) {
        hot.servisEdildi(tamami: true, sabirOrani: 1);
      }
      expect(hot.paraCarpani, 1.5);
      expect(hot.pismeCarpani, closeTo(1.35, 0.001));
      expect(hot.sabirCarpani, closeTo(1.25, 0.001));
    });

    test('the bands are the four the player is shown', () {
      final tempo = Tempo();
      for (var i = 0; i < 30; i++) {
        tempo.tick(1, bekleyen: true);
      }
      expect(tempo.hal, TempoHali.soguk);
      tempo
        ..servisEdildi(tamami: true, sabirOrani: 1)
        ..servisEdildi(tamami: true, sabirOrani: 1);
      expect(tempo.hal, TempoHali.normal);
    });
  });
}
