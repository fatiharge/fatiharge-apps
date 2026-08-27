import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/chain/domain/chain.dart';

void main() {
  DateTime day(int d) => DateTime(2026, 3, d);

  Chain marked(List<int> days) =>
      Chain(startedOn: day(days.first), markedDays: {for (final d in days) day(d)});

  group('streak', () {
    test('an unmarked today does not end the streak', () {
      // A streak breaks when a whole day goes by, not at midnight.
      expect(marked([1, 2, 3]).streakOn(day(4)), 3);
    });

    test('a marked today counts', () {
      expect(marked([1, 2, 3]).streakOn(day(3)), 3);
    });

    test('a missed day ends it', () {
      expect(marked([1, 2, 3]).streakOn(day(5)), 0);
    });

    test('only the run ending now counts, not the longest one ever', () {
      expect(marked([1, 2, 3, 8, 9]).streakOn(day(9)), 2);
    });

    test('marking twice in a day is marking once', () {
      final chain = Chain().mark(DateTime(2026, 3, 4, 9)).mark(DateTime(2026, 3, 4, 23));
      expect(chain.streakOn(day(4)), 1);
    });
  });

  group('breaking', () {
    test('today being open is not a break', () {
      expect(marked([1, 2]).isBrokenOn(day(3)), isFalse);
    });

    test('a whole day gone is', () {
      expect(marked([1, 2]).isBrokenOn(day(4)), isTrue);
    });
  });

  group('the monthly make-up', () {
    test('covers a single missed day', () {
      final chain = marked([1, 2]).freeze(day(4));

      expect(chain.streakOn(day(4)), 3);
      expect(chain.isMarked(day(3)), isTrue);
    });

    test('does not cover two, because that is not a slip', () {
      final chain = marked([1, 2]);

      expect(chain.canFreezeOn(day(5)), isFalse);
      expect(chain.freeze(day(5)).streakOn(day(5)), 0);
    });

    test('is spent once a month', () {
      final chain = marked([1, 2]).freeze(day(4));

      expect(chain.canFreezeOn(day(6)), isFalse);
      expect(chain.freezeSpentIn(day(20)), isTrue);
    });

    test('comes back the next month', () {
      final chain = marked([1, 2]).freeze(day(4));

      expect(chain.freezeSpentIn(DateTime(2026, 4, 1)), isFalse);
    });
  });
}
