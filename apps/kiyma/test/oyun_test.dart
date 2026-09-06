import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_rule.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tutor.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/gold_text.dart';

import 'support/counter_bot.dart';
import 'support/scene_from_disk.dart';

/// A whole game, start to finish, with nothing given away.
///
/// The one test that can see the shape of the thing: thirty days played by
/// the scripted player, buying what it can afford the way somebody would,
/// with the day's rule and the day's goal both live. It catches what no unit
/// test can — a rule whose goal cannot be reached, a day nothing clears, a
/// shop that runs out or never opens.
///
/// It prints the table it checks, because that table is how the numbers in
/// `Balance` get set.
void main() {
  late SceneData scene;
  setUpAll(() => scene = sceneFromDisk());

  test('thirty days, bought and played the way a player would', () {
    final progress = Progress();
    var kosu = 0;
    var gunKosusu = 0;
    var enIyi = 0;
    var saniye = 0.0;
    var seed = 0;
    final sorun = <String>[];
    int hedef(int gun) => math.max(
      1,
      (Balance.gunlukHedef(gun) * DayRule.forDay(gun).hedefCarpani).round(),
    );

    while (progress.gun <= 30 && kosu < 400) {
      final gun = progress.gun;
      // Buy whatever is affordable, cheapest first, the way a player would.
      var aldi = true;
      while (aldi) {
        aldi = false;
        for (final unlock in Unlocks.catalogue) {
          if (progress.unlocks.has(unlock.id)) continue;
          if (!progress.unlocks.available(unlock)) continue;
          if (progress.satinAl(unlock)) aldi = true;
        }
      }

      final ders = Lesson.bekleyen(progress) ?? Lesson.alimlar(progress);
      if (ders != null) progress.gordum(ders.gorulenler);

      final sonuc = CounterBot.play(scene, progress, skill: 0.6, seed: seed++);
      kosu++;
      saniye += Balance.runLength(gun).inSeconds;
      if (sonuc.kazanc <= 0) sorun.add('gun $gun: kosu hic kazandirmadi');
      if (sonuc.musteri == 0) sorun.add('gun $gun: hic musteri cikmadi');

      progress
        ..kazan(sonuc.kazanc)
        ..seviyeleriIsle();
      // The goal is per run and a heavy day takes several, so the question
      // is whether the day's best run could reach it — not every run.
      enIyi = math.max(enIyi, sonuc.musteri);
      if (progress.gun != gun && enIyi < hedef(gun)) {
        sorun.add(
          'gun $gun (${DayRule.forDay(gun).id}): hedefe hic ulasilamadi',
        );
      }
      if (progress.gun != gun) enIyi = 0;
      gunKosusu = progress.gun == gun ? gunKosusu + 1 : 0;
      if (gunKosusu >= 8) sorun.add('gun $gun: 8 kosuda gecilemedi');
      if (progress.gun != gun) {
        // The table is what the numbers in Balance were fitted to, so it
        // prints even when the test passes.
        // ignore: avoid_print
        print(
          'gun ${gun.toString().padLeft(2)} '
          '${DayRule.forDay(gun).id.padRight(10)} '
          'kosu=${(kosu).toString().padLeft(2)} '
          'kazanc=${goldText(sonuc.kazanc).padLeft(6)} '
          'musteri=${sonuc.musteri.toString().padLeft(2)}/'
          '${hedef(gun)} '
          'tempo=${sonuc.tempo.round()}',
        );
      }
    }

    // The summary line, printed for the same reason as the table.
    // ignore: avoid_print
    print(
      'BITTI gun=${progress.gun} kosu=$kosu '
      'dakika=${(saniye / 60).round()} '
      'para=${goldText(progress.para)} '
      'acik=${progress.unlocks.opened.length}/${Unlocks.catalogue.length + 5} '
      'kural=${DayRule.forDay(progress.gun).id}',
    );
    for (final line in sorun.toSet()) {
      // Named before the assertion so a failure says which day, not just
      // that there was one.
      // ignore: avoid_print
      print('SORUN $line');
    }
    expect(sorun, isEmpty);
    expect(progress.gun, greaterThan(30));
    expect(
      progress.unlocks.opened,
      hasLength(Unlocks.catalogue.length + 5),
      reason: 'the shop is meant to be finishable, and only just',
    );
    // Under three hours of counter time, so the game can be finished.
    expect(saniye / 60, lessThan(180));
  });
}
