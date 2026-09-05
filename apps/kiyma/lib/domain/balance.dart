import 'dart:math' as math;

import 'package:kiyma/domain/model/items.dart';

/// Every tunable number in the game, in one place.
///
/// The design doc marks these `[ÖNERİ]`: they are starting values waiting for
/// playtest, not mechanics. Three of them carry the difficulty — the cooked
/// window, the patience curve and the money target table — and the table was
/// derived from [income], so changing the income formula means recomputing
/// the table rather than nudging it.
abstract final class Balance {
  // --- Cooking (design doc 2.1) ---

  static const rawSeconds = 2.0;
  static const cookingSeconds = 4.0;

  /// The window where meat can be taken off, narrowing with the day.
  ///
  /// Twice the design doc's figures. Six seconds on day one read as a trap
  /// rather than as a window: by the time the player has noticed the skewer
  /// is ready and moved to it, most of it is gone.
  static double cookedWindow(int day) => math.max(5, 12 - day * 0.3);

  /// Charged the moment meat burns, not when it is binned. Money only —
  /// patience is untouched, which is what keeps the risk local and the third
  /// and fourth grill slots worth buying.
  static double burnPenalty(int day) => 10 * dayMultiplier(day);

  // --- Drinks (design doc 5.2) ---

  static const pourSeconds = 1.5;

  // --- Income (design doc 10.2) ---

  static double dayMultiplier(int day) => 1 + day * 0.08;

  static const durumBase = 10;
  static const porsiyonBase = 18;

  /// Flat, unscaled by the day: otherwise "stuff everything in" becomes the
  /// dominant late strategy.
  ///
  /// Big enough that a full wrap is worth roughly three bare ones. At the old
  /// +2 an ingredient was close to a pure loss: `OrderMaker` only asks for
  /// what is open, so buying one *created* orders that demanded it, and the
  /// whole return was two gold on an eleven-gold wrap.
  static const ingredientBonus = 5;

  static const Map<Tatli, int> tatliBase = {Tatli.baklava: 8};
  static const Map<Icecek, int> icecekBase = {
    Icecek.kola: 6,
    Icecek.ayran: 5,
    Icecek.salgam: 4,
  };

  static int income(int base, int day, {int ingredients = 0}) =>
      (base * dayMultiplier(day)).round() + ingredients * ingredientBonus;

  // --- Patience (design doc 8.4) ---

  static double patience(int day) => math.max(12, 30 - day * 0.6);

  /// Applied to what is *left*, not to the maximum: two refusals cost 36% of
  /// the remaining bar, not 40% of the whole one, so back-to-back refusals do
  /// not kill instantly.
  static const refusalKeeps = 0.8;

  // --- The day (design doc 11) ---

  /// How long the counter stays open. A run is a clock, not a queue:
  /// customers keep arriving as seats free until the time is up.
  static Duration runLength(int day) => Duration(seconds: 120 + day * 5);

  /// Gap between one customer leaving and the next taking the place.
  /// How long the quickest customer takes to walk in and settle, and how
  /// slow the slowest one is as a fraction of that. Everybody gets a speed
  /// somewhere in between, so a queue does not move as one body.
  /// Gold for a push the tempo meter had no room left to take.
  ///
  /// At the top of the meter a good move would otherwise be worth nothing;
  /// this turns the overflow into money, so playing well at full tempo keeps
  /// paying rather than going quiet.
  static const tempoBonus = 2.5;

  static const arrivalWalk = 2.0;
  static const slowestWalk = 0.4;

  /// How long the counter keeps pointing at the step a player just tried to
  /// skip.
  static const hintFor = 2.5;

  /// How long the grill and the wrap station may sit empty before the source
  /// that fills them starts asking for attention.
  static const idleGrill = 3.0;
  static const idleWrap = 4.0;

  /// How long a burnt skewer may sit on the grill before the bin asks for it.
  static const idleBurnt = 5.0;

  /// How long before the counter sweeps a pile up it starts flashing.
  static const sweptWarning = 3.0;

  /// Gold left on the ledge is swept into the till after this long, and only
  /// this much of it survives. Touching it is worth the difference.
  static const sweptAfter = 10.0;
  static const sweptKeeps = 0.7;

  /// Gap between arrivals, closing with the day.
  ///
  /// It was a flat three seconds, which made day one a firehose: the bot
  /// clears forty customers in a 185-second run and is limited by supply, not
  /// by its own hands. Day one should be teachable.
  static double arrivalGap(int day) => math.max(2.2, 8 - day * 0.6);

  /// XP needed to reach each day. Earned money is what feeds it, but the
  /// player is never shown that link — they see a level bar.
  ///
  /// Measured, not guessed: `test/economy_test.dart` plays whole runs with a
  /// scripted player and reports what they take. Each step is about what a
  /// plodding player clears in one run, so an ordinary day is one run and a
  /// good one is faster. The old table was out by a factor of twelve — a
  /// single day-one run cleared the first three days at once.
  static const targets = [
    240,
    525,
    870,
    1290,
    1800,
    2390,
    3070,
    3850,
    4730,
    5710,
  ];

  static int target(int day) {
    if (day <= targets.length) return targets[day - 1];
    // Past the hand-checked table, keep the second difference the table has.
    var value = targets.last;
    var step = targets.last - targets[targets.length - 2];
    for (var d = targets.length; d < day; d++) {
      step += 100;
      value += step;
    }
    return value;
  }

  /// Where the level [day] starts, in XP.
  static int floor(int day) => day <= 1 ? 0 : target(day - 1);

  /// How far through level [day] an XP total is, `0..1`.
  ///
  /// Here rather than on Progress or on a state object because the summary
  /// animates across days: it needs the curve as a function of an arbitrary
  /// day, not two scalars for the current one. It was written out three times
  /// before this, and only one copy was ever asserted.
  static double ratio(int xp, int day) {
    final span = target(day) - floor(day);
    return span <= 0 ? 1 : ((xp - floor(day)) / span).clamp(0, 1);
  }
}
