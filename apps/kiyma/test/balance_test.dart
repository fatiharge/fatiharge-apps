import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';

void main() {
  group('Balance', () {
    test('the cooked window narrows and then holds at 5s', () {
      expect(Balance.cookedWindow(1), closeTo(22, 0.001));
      expect(Balance.cookedWindow(9), closeTo(6, 0.001));
      expect(Balance.cookedWindow(60), 5);
    });

    test('patience shortens and then holds at 12s', () {
      expect(Balance.patience(1), closeTo(56.5, 0.001));
      expect(Balance.patience(30), 12);
      expect(Balance.patience(100), 12);
    });

    test('everything a day is worth compounds together', () {
      // The bonus rides the day with the base: an ingredient bought at a
      // compounding price cannot be worth less every day. What keeps
      // "stuff everything in" from dominating is the customer's `istemez`.
      final bare = Balance.income(Balance.durumBase, 1);
      final full = Balance.income(Balance.durumBase, 1, ingredients: 3);
      expect(full, greaterThan(bare));

      final lateBare = Balance.income(Balance.durumBase, 10);
      final lateFull = Balance.income(Balance.durumBase, 10, ingredients: 3);
      // Rounding at day one makes this approximate, not exact: the point is
      // that the gap grows with the day rather than staying flat.
      expect(
        (lateFull - lateBare) / (full - bare),
        closeTo(Balance.dayMultiplier(10), Balance.dayMultiplier(10) * 0.1),
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

    test('a run is a minute plus five seconds a day', () {
      expect(Balance.runLength(1), const Duration(seconds: 65));
      expect(Balance.runLength(10), const Duration(seconds: 110));
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
