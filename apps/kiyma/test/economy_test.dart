import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/unlocks.dart';

import 'support/counter_bot.dart';
import 'support/scene_from_disk.dart';

/// The economy, measured rather than guessed.
///
/// `DayRun` has no engine in it, so a whole run plays out in a loop with no
/// canvas and no clock. [CounterBot] is a plodding player — one thing at a
/// time, wraps only — so what it takes is a floor. The numbers in [Balance]
/// were set from this table; the assertions below are the shape that table
/// has to keep, not the figures themselves, which are meant to move.
void main() {
  late SceneData scene;
  setUpAll(() => scene = sceneFromDisk());

  ({int gold, int served, double tempo}) measure(
    int day, {
    required double skill,
    int runs = 5,
    bool bought = true,
  }) {
    var gold = 0;
    var served = 0;
    var tempo = 0.0;
    for (var seed = 0; seed < runs; seed++) {
      final progress = Progress()..gun = day;
      // What a player standing on day [day] would own. Measuring a bare
      // counter on day twenty says nothing: the shop is most of the curve.
      if (bought) {
        unlocksFor(day, spend: Balance.floor(day)).opened.forEach(
          progress.unlocks.open,
        );
      }
      final result = CounterBot.play(
        scene,
        progress,
        skill: skill,
        seed: seed,
      );
      gold += result.kazanc;
      served += result.musteri;
      tempo += result.tempo;
    }
    return (
      gold: (gold / runs).round(),
      served: (served / runs).round(),
      tempo: tempo / runs,
    );
  }

  test('a day is about one run, and falling behind is the player', () {
    final rows = <int, ({int slow, int fast})>{};
    // The table is the point of the test: it is how the numbers in Balance
    // get set, so it prints even when it passes.
    // ignore: avoid_print
    print('day  plodding  skilled  step  runs');
    for (final day in [1, 2, 3, 5, 8, 10, 15, 20, 30]) {
      final slow = measure(day, skill: 0.6);
      final fast = measure(day, skill: 1);
      final step = Balance.target(day) - Balance.floor(day);
      rows[day] = (slow: slow.gold, fast: fast.gold);
      // Same reason as the header above.
      // ignore: avoid_print
      print(
        '${day.toString().padLeft(3)}'
        '  ${slow.gold.toString().padLeft(8)}'
        '  ${fast.gold.toString().padLeft(7)}'
        '  ${step.toString().padLeft(11)}'
        '  ${(step / slow.gold).toStringAsFixed(2).padLeft(5)}',
      );
    }

    // Day one is teachable: one unhurried run clears it.
    expect(rows[1]!.slow, greaterThanOrEqualTo(Balance.target(1)));

    // An ordinary day is about one run; every fifth is deliberately two, so
    // there is a day the player has to come back to.
    for (final entry in rows.entries) {
      final day = entry.key;
      final step = Balance.target(day) - Balance.floor(day);
      // Checked against the curve rather than a figure: the table is built
      // from `gunKosusu`, so this asserts the two still agree. The band is
      // wide because the scripted player's take swings about a sixth
      // between samples, and a tighter one would measure the seed.
      final runs = step / entry.value.slow;
      expect(
        runs,
        lessThan(Balance.gunKosusu(day) * 1.4),
        reason: 'day $day takes too many runs to clear',
      );
      expect(
        runs,
        greaterThan(Balance.gunKosusu(day) * 0.6),
        reason: 'day $day is free',
      );
    }
    expect(
      rows.keys.where(Balance.agirGun),
      isNotEmpty,
      reason: 'the table has to sample a heavy day',
    );

    // Skill is worth little on day one and a great deal by day ten. That
    // widening is the difficulty curve; without it the game has none.
    final early = rows[1]!.fast / rows[1]!.slow;
    final late =
        rows[Balance.targets.length]!.fast / rows[Balance.targets.length]!.slow;
    expect(early, lessThan(1.3));
    // Stated as a widening rather than as a number: what matters is that
    // skill is worth more on day ten than on day one, and the absolute
    // figure moves every time the scripted player learns anything.
    expect(late, greaterThan(early * 1.25));
  });

  test('the tempo meter moves instead of pinning', () {
    final easy = measure(1, skill: 1).tempo;
    final hard = measure(10, skill: 0.6).tempo;

    expect(
      easy,
      lessThan(95),
      reason: 'a full meter is a constant, not a meter',
    );
    expect(
      easy,
      greaterThan(55),
      reason: 'and an unhurried day is not a cold one',
    );
    // A busy counter handled badly reads lower than a quiet one handled well.
    expect(hard, lessThan(easy + 10));
  });

  test('the shop lasts as long as the game does', () {
    final son = Balance.targets.length;
    final shop = Unlocks.catalogue.fold(0, (sum, u) => sum + u.price);
    // Affordable in the end, so the ladders are not decoration.
    expect(shop, lessThan(Balance.target(son)));
    // And only just. The ladders come to two thirds of everything the game
    // ever pays, so there is no point at which they are all owned and the
    // shop stops being a decision.
    expect(shop, greaterThan(Balance.target(son) * 0.5));
  });
}
