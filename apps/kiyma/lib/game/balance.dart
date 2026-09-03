import 'dart:math' as math;

import 'package:kiyma/game/model/items.dart';

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

  /// The window where meat can be taken off, narrowing until day 24.
  static double cookedWindow(int day) => math.max(2.5, 6 - day * 0.15);

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
  static const ingredientBonus = 2;

  static const Map<Tatli, int> tatliBase = {
    Tatli.baklava: 8,
    Tatli.kunefe: 7,
    Tatli.sutlac: 5,
  };
  static const Map<Icecek, int> icecekBase = {
    Icecek.kola: 6,
    Icecek.ayran: 5,
    Icecek.salgam: 4,
  };

  static int income(int base, int day, {int ingredients = 0}) =>
      (base * dayMultiplier(day)).round() + ingredients * ingredientBonus;

  // --- Patience and reputation (design doc 8.4, 9) ---

  static double patience(int day) => math.max(12, 30 - day * 0.6);

  /// Applied to what is *left*, not to the maximum: two refusals cost 36% of
  /// the remaining bar, not 40% of the whole one, so back-to-back refusals do
  /// not kill instantly.
  static const refusalKeeps = 0.8;

  static const startingReputation = 70;

  /// Never below this. The repeat-the-day rule already stops the death
  /// spiral; this stops the flow of customers drying up mid-day.
  static const reputationFloor = 30;
  static const reputationCeiling = 100;

  static const reputationServed = 1;
  static const reputationPartial = -4;
  static const reputationNothing = -8;

  // --- The day (design doc 11) ---

  static int baseCustomers(int day) => 5 + day * 2;

  static int customerCount(int day, int reputation) =>
      (baseCustomers(day) * (0.7 + 0.3 * reputation / 100)).round();

  /// Gap between one customer leaving and the next taking the place.
  static const arrivalGap = 1.5;

  /// Cumulative earnings needed to pass the day — roughly 70% of what a
  /// competent player takes, so it is a floor rather than a wall. Derived
  /// from [income]; recompute if that changes.
  static const targets = [70, 170, 295, 450, 640, 865, 1125, 1425, 1770, 2155];

  static int target(int day) {
    if (day <= targets.length) return targets[day - 1];
    // Past the hand-checked table, keep the second difference the table has.
    var value = targets.last;
    var step = targets.last - targets[targets.length - 2];
    for (var d = targets.length; d < day; d++) {
      step += 40;
      value += step;
    }
    return value;
  }
}
