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
  /// Day one opens at twice what it used to and closes on the old floor by
  /// day ten. A first run is where the player is still looking for the bin,
  /// and a window that shuts while they look teaches nothing except that the
  /// grill is unfair. What it costs is nothing: day one barely pays, so the
  /// slack is spent on somebody learning rather than on somebody farming.
  static double cookedWindow(int day, {int komur = 0}) =>
      math.max(5, 24 - day * 2.0) + komur * komurPencere;

  /// How many handfuls make one ingredient.
  ///
  /// One drag used to fill a well, which made a loaded wrap four flicks and
  /// no decision. Three turns each ingredient into something being *built*:
  /// the strip grows a third at a time, so a half-finished wrap is visible
  /// and abandoning one has a cost.
  static const tutamAdedi = 3;

  /// What a sharper knife takes it down to, one handful per rung. One is the
  /// floor: an ingredient that goes on in a single touch is a tray again,
  /// not a build.
  static int tutam(int bicak) => math.max(1, tutamAdedi - bicak);

  /// Coal, per rung: the cook shortens and the window widens. The grill
  /// feeds every other line, which is why this is the one ladder that raises
  /// the ceiling on all of them.
  static const komurHizi = 0.93;
  static const komurPencere = 1.1;

  static double komurCarpani(int kademe) =>
      math.pow(komurHizi, kademe).toDouble();

  /// Charged the moment meat burns, not when it is binned. Money only —
  /// patience is untouched, which is what keeps the risk local and the third
  /// and fourth grill slots worth buying.
  static double burnPenalty(int day) => dayMultiplier(day);

  // --- Drinks (design doc 5.2) ---

  static const pourSeconds = 1.5;

  // --- Income (design doc 10.2) ---

  /// What a day is worth, compounding.
  ///
  /// It used to be `1 + day * 0.08`, and the level targets were fitted to
  /// cancel it out — a treadmill by construction, where day ten paid 2.6x
  /// day one and nothing ever felt like progress. Compounding is the whole
  /// point of a progression: the numbers have to run away.
  ///
  /// The base is 1.79 because that is the curve through the three points the
  /// game was asked for — a day worth 30 pays 90 on day three and 560 on day
  /// six. Every other number here is measured; this one was specified.
  static double dayMultiplier(int day) => math.pow(1.79, day - 1).toDouble();

  static const durumBase = 1;
  static const porsiyonBase = 2;

  /// Flat, unscaled by the day: otherwise "stuff everything in" becomes the
  /// dominant late strategy.
  ///
  /// Rides the day with everything else, or the ingredients a player just
  /// paid a compounding price for would be worth less every day.
  ///
  /// Still flat *within* a day, so "stuff everything in" never becomes the
  /// dominant late strategy — the customer's `istemez` is what pushes back.
  static const ingredientBonus = 0.7;

  static const Map<Tatli, int> tatliBase = {Tatli.baklava: 1};
  static const Map<Icecek, int> icecekBase = {
    Icecek.kola: 1,
    Icecek.ayran: 1,
    Icecek.salgam: 1,
  };

  /// Better mince, per rung. Added to the base rather than multiplied onto
  /// the takings: a multiplier on a compounding day is how an economy runs
  /// away from the table that was fitted to it.
  static const kasapPayi = 0.2;

  static int income(num base, int day, {int ingredients = 0}) =>
      ((base + ingredients * ingredientBonus) * dayMultiplier(day)).round();

  // --- Patience (design doc 8.4) ---

  /// A courtesy the counter can buy: flat seconds rather than a fraction,
  /// because a late day cuts the bar to a twelve-second floor and a
  /// percentage of a floor is nothing.
  static const ikramSaniye = 3.0;

  /// Also doubled at the top and converging on the same floor, for the same
  /// reason as [cookedWindow]: the first days are the ones being learnt.
  static double patience(int day, {int ikram = 0}) =>
      math.max(12, 60 - day * 3.5) + ikram * ikramSaniye;

  // --- Who walked in ---

  /// How much less time a hurried customer gives you, and how much more they
  /// pay for it. The pair has to be worth taking: a shorter bar that paid the
  /// same would just be a worse customer.
  static const aceleciSabir = 0.6;
  static const aceleciOdeme = 1.4;

  /// A fussy customer names two things they will not have. Worth more
  /// because two forbidden ingredients is a real constraint on a wrap that
  /// only holds four.
  static const titizIstemez = 2;
  static const titizOdeme = 1.3;

  /// A generous customer tips this much of the main product on top, but only
  /// if the bar is still above [comertEsigi] when it lands. Nothing to read:
  /// serve them early and the coins say so.
  static const comertBahsis = 0.45;
  static const comertEsigi = 0.55;

  /// Where in the wait an indecisive customer changes their mind. Late
  /// enough that the first build is usually underway, early enough that
  /// there is time to fix it.
  static const kararsizAn = 0.55;

  /// Applied to what is *left*, not to the maximum: two refusals cost 36% of
  /// the remaining bar, not 40% of the whole one, so back-to-back refusals do
  /// not kill instantly.
  static const refusalKeeps = 0.8;

  // --- The day (design doc 11) ---

  /// How long the counter stays open. A run is a clock, not a queue:
  /// customers keep arriving as seats free until the time is up.
  /// A minute, not two. Two minutes of the same four gestures is where a
  /// run stops being a push and becomes a shift; the day ends while the
  /// player still wants one more customer, which is the point.
  static Duration runLength(int day) => Duration(seconds: 60 + day * 5);

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

  /// A bigger till, per rung: money sits longer and less of it goes when the
  /// counter sweeps. Capped short of the whole pile — a sweep that costs
  /// nothing is a sweep nobody reaches for.
  static const kasaSaniye = 3.0;
  static const kasaOrani = 0.06;

  static double supurulmeSuresi(int kasa) => sweptAfter + kasa * kasaSaniye;

  static double supurulenPay(int kasa) =>
      math.min(0.9, sweptKeeps + kasa * kasaOrani);

  /// What an apprentice is worth: the meter cools this much slower per rung.
  /// It buys nothing on a good run, only room to recover on a bad one.
  static const cirakSizma = 0.85;

  static double sizmaCarpani(int cirak) =>
      math.pow(cirakSizma, cirak).toDouble();

  /// A wider jug mouth, per rung.
  static const surahiHizi = 0.75;

  static double dokumSuresi(int kademe) =>
      pourSeconds * math.pow(surahiHizi, kademe);

  /// Gap between arrivals, closing with the day.
  ///
  /// It was a flat three seconds, which made day one a firehose: the bot
  /// clears forty customers in a 185-second run and is limited by supply, not
  /// by its own hands. Day one should be teachable.
  /// A sign outside brings people in faster. Applied to the floor too, or it
  /// would be dead from day ten on — and it can never fill a place the
  /// counter does not have, which is what stops it being the only rung worth
  /// buying.
  static const tabelaCarpani = 0.9;

  static double arrivalGap(int day, {int tabela = 0}) =>
      math.max(2.2, 8 - day * 0.6) * math.pow(tabelaCarpani, tabela);

  /// How far into the day the doors shut.
  ///
  /// Nobody new comes in after this; whoever is already at the counter still
  /// has to be served. A run that simply stops mid-order is a run that ends
  /// by taking something away from the player.
  static const sonSiparis = 0.88;

  /// How long past the buzzer the last orders may take before the day is
  /// closed anyway. Without a cap a player who puts the phone down holds the
  /// day open for as long as the customers' patience lasts.
  static const kapanisPayi = 25.0;

  // --- A good stretch ---

  /// A tip every fifth customer in a row: often enough that a good run pays
  /// twice, rare enough that it is not the per-serve reward again. Worth one
  /// bare wrap per step so it rides the day with everything else, and it
  /// stops growing so the exposure to the target table stops widening.
  static const seriIkramiyeAdimi = 5;
  static const seriIkramiyeCarpani = 1.2;
  static const seriIkramiyeTavani = 3;

  static int seriIkramiyesi(int seri, int day) {
    final adim = math.min(seriIkramiyeTavani, seri ~/ seriIkramiyeAdimi);
    return adim <= 0 ? 0 : income(durumBase * seriIkramiyeCarpani * adim, day);
  }

  /// The bottom of the patience bar — the same boundary the body already
  /// turns red at, so the state that pays is the one the player learned to
  /// read. Half again, on the item that finishes the visit only.
  static const kritikSabir = 0.2;
  static const kritikCarpani = 1.5;

  /// What a day has to have gone like to be worth saying so.
  static const rozetSeri = 10;
  static const rozetKritik = 3;

  // --- What today is (design doc 11.3) ---

  /// The first day that carries a named rule. Days one to three stay clean:
  /// the trade shape arrives on day two and the usta explains it on day
  /// three, so day four is the first card with a reader for a second name.
  static const ilkKuralGunu = 4;

  /// An inspection pays half again and forgives nothing. The reward is what
  /// makes zero forgiveness a trade rather than a tax.
  static const denetimOdemesi = 1.5;
  static const denetimBagislanan = 0;

  /// A cooler grill: one slot fewer, and a window half again as wide so the
  /// day is different rather than simply worse. Two slots is the floor no
  /// rule may take the counter below — it is day one's grill.
  static const komurKesintisi = 1;
  static const komurPenceresi = 1.5;
  static const enAzMangal = 2;

  /// Wraps only puts every customer through the one prep area, which is the
  /// counter's known choke point. The premium stops the day reading as a
  /// punishment for having bought the plate line.
  static const durumGunuOdemesi = 1.3;

  /// One more named ingredient per order, which costs handfuls and makes the
  /// ingredient bonus — otherwise an invisible rule — the point of the day.
  static const titizEkMalzeme = 1;

  /// How often an order carries an extra. Tunables, so they live here.
  static const tatliSansi = 0.35;
  static const icecekSansi = 0.4;

  /// A holiday means everybody, not most. The bend is that every visit needs
  /// two handovers, so seats turn over slower; that is reward enough.
  static const bayramTatliSansi = 1.0;

  /// How many customers a day asks to be sent away happy, and what hitting
  /// it pays. The reward is a share of the day's own level step, so it keeps
  /// its worth forever without a second table to maintain.
  static const gunlukHedefTaban = 5.0;
  static const gunlukHedefEgim = 0.9;
  static const gunlukHedefTavan = 14;
  static const gunlukOdulPayi = 0.15;

  static int gunlukHedef(int day) => math.min(
    gunlukHedefTavan,
    (gunlukHedefTaban + gunlukHedefEgim * (day - 1)).round(),
  );

  static int gunlukOdul(int day) =>
      ((target(day) - floor(day)) * gunlukOdulPayi).round();

  /// XP needed to reach each day. Earned money is what feeds it, but the
  /// player is never shown that link — they see a level bar.
  ///
  /// Measured, not guessed: `test/economy_test.dart` plays whole runs with a
  /// scripted player and reports what they take. Each step is about what a
  /// plodding player clears in one run, so an ordinary day is one run and a
  /// good one is faster. The old table was out by a factor of twelve — a
  /// single day-one run cleared the first three days at once.
  static const targets = [
    11,
    34,
    80,
    180,
    395,
    875,
    1825,
    3700,
    7060,
    13060,
  ];

  static int target(int day) {
    if (day <= targets.length) return targets[day - 1];
    // Past the hand-checked table, keep the second difference the table has.
    var value = targets.last;
    var step = targets.last - targets[targets.length - 2];
    for (var d = targets.length; d < day; d++) {
      // Compounds past the table at the rate the income does: anything
      // slower and every day after the tenth would clear on its first run.
      step = (step * 1.79).round();
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
