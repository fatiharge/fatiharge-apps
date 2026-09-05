import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';

void main() {
  group('Balance', () {
    test('the cooked window narrows and then holds at 5s', () {
      expect(Balance.cookedWindow(1), closeTo(11.7, 0.001));
      expect(Balance.cookedWindow(24), closeTo(5, 0.001));
      expect(Balance.cookedWindow(60), 5);
    });

    test('patience shortens and then holds at 12s', () {
      expect(Balance.patience(1), closeTo(29.4, 0.001));
      expect(Balance.patience(30), 12);
      expect(Balance.patience(100), 12);
    });

    test('ingredient bonuses do not scale with the day', () {
      final early = Balance.income(Balance.durumBase, 1, ingredients: 3);
      final late = Balance.income(Balance.durumBase, 20, ingredients: 3);
      const three = 3 * Balance.ingredientBonus;
      expect(early - Balance.income(Balance.durumBase, 1), three);
      expect(late - Balance.income(Balance.durumBase, 20), three);
    });

    test('a run is two minutes plus five seconds a day', () {
      expect(Balance.runLength(1), const Duration(seconds: 125));
      expect(Balance.runLength(10), const Duration(seconds: 170));
    });

    test('the target table climbs, and keeps climbing past its end', () {
      expect(Balance.target(1), Balance.targets.first);
      expect(Balance.target(10), Balance.targets.last);
      expect(Balance.target(11), greaterThan(Balance.target(10)));
      expect(
        Balance.target(12) - Balance.target(11),
        greaterThan(Balance.target(11) - Balance.target(10)),
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
