import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/balance.dart';

void main() {
  group('Balance', () {
    test('the cooked window narrows and then holds at 2.5s', () {
      expect(Balance.cookedWindow(1), closeTo(5.85, 0.001));
      expect(Balance.cookedWindow(24), closeTo(2.5, 0.001));
      expect(Balance.cookedWindow(60), 2.5);
    });

    test('patience shortens and then holds at 12s', () {
      expect(Balance.patience(1), closeTo(29.4, 0.001));
      expect(Balance.patience(30), 12);
      expect(Balance.patience(100), 12);
    });

    test('ingredient bonuses do not scale with the day', () {
      final early = Balance.income(Balance.durumBase, 1, ingredients: 3);
      final late = Balance.income(Balance.durumBase, 20, ingredients: 3);
      expect(early - Balance.income(Balance.durumBase, 1), 6);
      expect(late - Balance.income(Balance.durumBase, 20), 6);
    });

    test('customer count scales with reputation', () {
      expect(Balance.customerCount(1, 100), Balance.baseCustomers(1));
      expect(
        Balance.customerCount(10, 0),
        (Balance.baseCustomers(10) * 0.7).round(),
      );
    });

    test('the target table is the doc table, and keeps climbing past it', () {
      expect(Balance.target(1), 70);
      expect(Balance.target(10), 2155);
      expect(Balance.target(11), greaterThan(Balance.target(10)));
      expect(
        Balance.target(12) - Balance.target(11),
        greaterThan(Balance.target(11) - Balance.target(10)),
      );
    });
  });
}
