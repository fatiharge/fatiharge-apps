import 'dart:math' as math;

import 'package:kiyma/domain/model/items.dart';

/// Every tunable number in the game, in one place.
///
/// [targets] is measured, not chosen: `test/economy_test.dart` plays whole
/// runs and the table is fitted to what they take. Changing [income] or any
/// curve above it means refitting the table rather than nudging it.
abstract final class Balance {
  // --- Cooking (design doc 2.1) ---

  static const rawSeconds = 2.0;
  static const cookingSeconds = 4.0;

  /// How long meat stays good, narrowing slowly and stopping well short of
  /// tight. A later day is harder because it wants more people through the
  /// counter, not because it gives less time per skewer.
  static double cookedWindow(int day, {int komur = 0}) =>
      math.max(16, 34 - day * 0.6) + komur * komurPencere;

  /// Handfuls per ingredient before any knife. Three, so a wrap is built
  /// rather than flicked together and abandoning a half-made one costs.
  static const tutamBasi = 3;

  /// What a sharper knife takes it down to, one per rung. One is the floor:
  /// an ingredient that goes on in a single touch is a tray again.
  static int tutam(int bicak) => math.max(1, tutamBasi - bicak);

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

  /// What a day is worth, compounding. Over thirty days it comes to about a
  /// million times day one, which is the point: the numbers have to run away
  /// or the shop is a treadmill.
  static double dayMultiplier(int day) => math.pow(1.62, day - 1).toDouble();

  static const durumBase = 1;
  static const porsiyonBase = 2;

  /// What one named ingredient adds, as a share of the base — so the shop
  /// can say "+80%" and mean it on every day. Rides the day with everything
  /// else; what stops "stuff everything in" is the customer's `istemez`.
  static const ingredientBonus = 0.8;

  static const Map<Dessert, int> tatliBase = {Dessert.baklava: 1};
  static const Map<Drink, int> icecekBase = {
    Drink.kola: 1,
    Drink.ayran: 1,
    Drink.salgam: 1,
  };

  /// Better mince, per rung. Added to the base rather than multiplied onto
  /// the takings: a multiplier on a compounding day is how an economy runs
  /// away from the table that was fitted to it.
  static const kasapPayi = 0.2;

  static int income(num base, int day, {int ingredients = 0}) =>
      ((base + ingredients * ingredientBonus) * dayMultiplier(day)).round();

  // --- Patience (design doc 8.4) ---

  /// A courtesy the counter can buy: flat seconds rather than a fraction, so
  /// it is worth the same on the day the bar is shortest.
  static const ikramSaniye = 3.0;

  /// How long somebody waits, on the same slow curve as [cookedWindow] and
  /// for the same reason.
  static double patience(int day, {int ikram = 0}) =>
      math.max(34, 80 - day * 1.5) + ikram * ikramSaniye;

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

  /// How long the counter stays open — a clock, not a queue. A minute on
  /// day one, four by day thirty: the first is short enough to learn on and
  /// the last long enough to be worth the counter it is played on.
  static Duration runLength(int day) => Duration(seconds: 60 + day * 6);

  /// Gold for a push the meter had no room left to take, so playing well at
  /// full tempo keeps paying rather than going quiet.
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

  /// A sign outside brings people in faster. Applied to the floor too, or it
  /// would be dead from the day the gap bottoms out — and it can never fill
  /// a place the counter does not have.
  static const tabelaCarpani = 0.9;

  static double arrivalGap(int day, {int tabela = 0}) =>
      math.max(1.5, 6 - day * 0.15) * math.pow(tabelaCarpani, tabela);

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

  /// A day played at speed: two thirds of the patience, half again the pay.
  /// The trade has to be worth taking or it is only a worse day.
  static const kosuSabri = 0.65;
  static const kosuOdemesi = 1.5;

  /// The other end of the same trade — time instead of money.
  static const sakinPenceresi = 1.4;
  static const sakinSabri = 1.35;
  static const sakinOdemesi = 0.85;

  /// A holiday means everybody, not most. The bend is that every visit needs
  /// two handovers, so seats turn over slower; that is reward enough.
  static const bayramTatliSansi = 1.0;

  /// How many customers a day asks to be sent away happy, and what hitting
  /// it pays. The reward is a share of the day's own level step, so it keeps
  /// its worth forever without a second table to maintain.
  static const gunlukHedefTaban = 2.5;
  static const gunlukHedefTavan = 8.0;
  static const gunlukHedefYari = 12.0;
  static const gunlukOdulPayi = 0.15;

  /// Customers a minute the day asks for. The one number the player is
  /// actually playing against: the timers are generous and stay generous, so
  /// a later day is harder because it wants more people through the counter,
  /// not because it gives less time per person.
  /// Saturating, not linear. A fully bought counter tops out near nine
  /// customers a minute whoever is holding the phone — the grill and the
  /// three places are the ceiling, not the hands — so a goal that kept
  /// climbing would stop being a goal and start being a wall.
  static double hedefTempo(int day) =>
      gunlukHedefTavan -
      (gunlukHedefTavan - gunlukHedefTaban) *
          math.exp(-(day - 1) / gunlukHedefYari);

  static int gunlukHedef(int day) =>
      (hedefTempo(day) * runLength(day).inSeconds / 60).round();

  static int gunlukOdul(int day) =>
      ((target(day) - floor(day)) * gunlukOdulPayi).round();

  /// XP needed to reach each day. Earned money feeds it; the player sees a
  /// level bar and never the link.
  ///
  /// Measured, not guessed, and fitted to [gunKosusu]: each step is what a
  /// plodding player takes in that many runs.
  static const targets = [
    18,
    56,
    187,
    363,
    715,
    1338,
    3198,
    5738,
    10688,
    20408,
    46608,
    80408,
    146408,
    274408,
    786408,
    1164408,
    1847408,
    3847408,
    6487408,
    13387408,
    21557408,
    53857408,
    95057408,
    142557408,
    264557408,
    404557408,
    807557408,
    1907557408,
    2741557408,
    3921557408,
  ];

  /// How many runs a day is worth, already baked into [targets].
  ///
  /// A game where every day is one run is a straight line, so this climbs:
  /// day one clears in a single unhurried run and day thirty takes three.
  /// Every fifth day is heavier again, which is where the player replays,
  /// banks the second run and walks into the shop with something to spend.
  static const gunKosuTabani = 0.9;
  static const kosuEgimi = 0.045;

  /// The days that are worth replaying for. Each one carries exactly one
  /// thing in the shop: the player grinds the day, banks the second run and
  /// buys it. Listed rather than derived — the rhythm is the design, and a
  /// modulus would space them evenly, which is the one thing it must not do.
  static const agirGunler = {3, 7, 11, 15, 18, 20, 22, 23, 25, 27, 28};
  static const agirGunPayi = 1.5;

  /// The three the run bends around, each in front of one expensive thing.
  static const fazlaGunler = {15, 22, 28};
  static const fazlaGunPayi = 2.2;

  static bool agirGun(int day) => agirGunler.contains(day);

  static double gunKosusu(int day) =>
      (gunKosuTabani + (day - 1) * kosuEgimi) *
      (fazlaGunler.contains(day)
          ? fazlaGunPayi
          : agirGun(day)
          ? agirGunPayi
          : 1);

  static int target(int day) {
    if (day <= targets.length) return targets[day - 1];
    // Past the table, compounding at the rate the income does — anything
    // slower and every later day would clear on its first run.
    var value = targets.last;
    var step = targets.last - targets[targets.length - 2];
    for (var d = targets.length; d < day; d++) {
      step = (step * 1.62).round();
      value += step;
    }
    return value;
  }

  /// Where the level [day] starts, in XP.
  static int floor(int day) => day <= 1 ? 0 : target(day - 1);

  /// How far through level [day] an XP total is, `0..1`. Here rather than on
  /// Progress because the summary animates across days and needs the curve
  /// for an arbitrary one.
  static double ratio(int xp, int day) {
    final span = target(day) - floor(day);
    return span <= 0 ? 1 : ((xp - floor(day)) / span).clamp(0, 1);
  }
}
