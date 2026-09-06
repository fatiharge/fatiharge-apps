import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';

void main() {
  group('Balance', () {
    // The two timers stay generous on purpose. A later day is harder
    // because it wants more people through the counter, not because it gives
    // less time per person — so both of these decay slowly and stop well
    // above the point where they would be played by luck.
    test('the cooked window narrows slowly and never gets tight', () {
      expect(Balance.cookedWindow(1), closeTo(33.4, 0.001));
      expect(Balance.cookedWindow(30), closeTo(16, 0.001));
      expect(Balance.cookedWindow(100), 16);
    });

    test('patience shortens slowly and holds above half a minute', () {
      expect(Balance.patience(1), closeTo(78.5, 0.001));
      expect(Balance.patience(30), closeTo(35, 0.001));
      expect(Balance.patience(100), 34);
    });

    test('the goal saturates below what a full counter can serve', () {
      expect(Balance.hedefTempo(1), closeTo(Balance.gunlukHedefTaban, 0.001));
      // Measured: a bought-out counter tops out near nine a minute, so the
      // curve has to converge under that rather than climb through it.
      expect(Balance.hedefTempo(30), lessThan(Balance.gunlukHedefTavan));
      expect(Balance.gunlukHedefTavan, lessThan(9));
      expect(Balance.gunlukHedef(1), 3);
      expect(Balance.gunlukHedef(30), greaterThan(Balance.gunlukHedef(10)));
    });

    test('everything a day is worth compounds together', () {
      // The bonus rides the day with the base: an ingredient bought at a
      // compounding price cannot be worth less every day. What keeps
      // "stuff everything in" from dominating is the customer's `istemez`.
      final bare = Balance.income(Balance.durumBase, 1);
      final full = Balance.income(Balance.durumBase, 1, ingredients: 3);
      expect(full, greaterThan(bare));

      // Stated as a share rather than a gap, which is how the shop says it
      // too: three ingredients are worth the same multiple of a bare wrap on
      // day thirty as on day one.
      const pay = 1 + 3 * Balance.ingredientBonus / Balance.durumBase;
      expect(full / bare, closeTo(pay, 0.5));
      expect(
        Balance.income(Balance.durumBase, 30, ingredients: 3) /
            Balance.income(Balance.durumBase, 30),
        closeTo(pay, 0.01),
      );
    });

    test('a day is worth a great deal more than the one before it', () {
      // The old curve was +8% a day and the targets cancelled it out: day ten
      // paid 2.6x day one and nothing ever felt like progress.
      expect(Balance.dayMultiplier(1), 1);
      expect(
        Balance.dayMultiplier(10) / Balance.dayMultiplier(1),
        greaterThan(25),
      );
    });

    test('a run is a minute on day one and four by day thirty', () {
      expect(Balance.runLength(1), const Duration(seconds: 66));
      expect(Balance.runLength(10), const Duration(seconds: 120));
      expect(Balance.runLength(30), const Duration(seconds: 240));
    });

    test('the target table climbs, and keeps climbing past its end', () {
      expect(Balance.target(1), Balance.targets.first);
      expect(Balance.target(Balance.targets.length), Balance.targets.last);
      final n = Balance.targets.length;
      expect(Balance.target(n + 1), greaterThan(Balance.target(n)));
      expect(
        Balance.target(n + 2) - Balance.target(n + 1),
        greaterThan(Balance.target(n + 1) - Balance.target(n)),
      );
    });

    test('the level curve is measured from the level it is in', () {
      // One curve, three readers: the day card, the summary and Progress. It
      // was written out three times before it lived here.
      expect(Balance.floor(1), 0);
      expect(Balance.floor(3), Balance.target(2));

      expect(Balance.ratio(0, 1), 0);
      expect(Balance.ratio(Balance.target(1), 1), 1);
      expect(Balance.ratio(Balance.target(2), 3), 0, reason: 'a fresh level');
      expect(Balance.ratio(-50, 1), 0, reason: 'a losing run cannot go under');
      expect(Balance.ratio(1 << 20, 1), 1, reason: 'nor over');
    });
  });
}
