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
  }) {
    var gold = 0;
    var served = 0;
    var tempo = 0.0;
    for (var seed = 0; seed < runs; seed++) {
      final result = CounterBot.play(
        scene,
        Progress()..gun = day,
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
    print('day  plodding  skilled  step');
    for (final day in [1, 2, 3, 5, 8, 10]) {
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
        '  ${step.toString().padLeft(4)}',
      );
    }

    // Day one is teachable: one unhurried run clears it.
    expect(rows[1]!.slow, greaterThanOrEqualTo(Balance.target(1)));

    // And no day is ever more than a few runs, however badly it goes.
    for (final entry in rows.entries) {
      final step = Balance.target(entry.key) - Balance.floor(entry.key);
      expect(
        step / entry.value.slow,
        lessThan(2.5),
        reason: 'day ${entry.key} takes too many runs to clear',
      );
    }

    // Skill is worth little on day one and a great deal by day ten. That
    // widening is the difficulty curve; without it the game has none.
    expect(rows[1]!.fast / rows[1]!.slow, lessThan(1.3));
    expect(rows[10]!.fast / rows[10]!.slow, greaterThan(1.8));
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

  test('the shop costs more than ten days of play', () {
    final shop = Unlocks.catalogue.fold(0, (sum, u) => sum + u.price);
    expect(shop, greaterThan(Balance.target(10)));
    expect(
      shop,
      lessThan(Balance.target(10) * 2),
      reason: 'out of reach is not a choice either',
    );
  });
}
