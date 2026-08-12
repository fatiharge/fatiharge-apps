import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/rules/summary_schedule.dart';

void main() {
  group('occurrencesAfter', () {
    test('starts after the given moment, never on it', () {
      final from = DateTime(2026, 8, 1, SummarySchedule.hour);

      final next = SummarySchedule.occurrencesAfter(from, day: 1, count: 1);

      expect(next.single, DateTime(2026, 9, 1, SummarySchedule.hour));
    });

    test('walks forward one month at a time', () {
      final next = SummarySchedule.occurrencesAfter(
        DateTime(2026, 8, 12),
        day: 15,
        count: 3,
      );

      expect(next, [
        DateTime(2026, 8, 15, SummarySchedule.hour),
        DateTime(2026, 9, 15, SummarySchedule.hour),
        DateTime(2026, 10, 15, SummarySchedule.hour),
      ]);
    });

    test('rolls over the year', () {
      final next = SummarySchedule.occurrencesAfter(
        DateTime(2026, 12, 20),
        day: 5,
        count: 2,
      );

      expect(next, [
        DateTime(2027, 1, 5, SummarySchedule.hour),
        DateTime(2027, 2, 5, SummarySchedule.hour),
      ]);
    });

    test('the 31st lands on the last day of shorter months', () {
      final next = SummarySchedule.occurrencesAfter(
        DateTime(2026),
        day: 31,
        count: 4,
      );

      expect(next.map((d) => '${d.month}/${d.day}'), [
        '1/31',
        '2/28', // not skipped, which is the bug this rule exists for
        '3/31',
        '4/30',
      ]);
    });

    test('February gets its 29th in a leap year', () {
      final next = SummarySchedule.occurrencesAfter(
        DateTime(2028, 2),
        day: 30,
        count: 1,
      );

      expect(next.single, DateTime(2028, 2, 29, SummarySchedule.hour));
    });

    test('every chosen day produces an occurrence every month', () {
      for (
        var day = SummarySchedule.firstDay;
        day <= SummarySchedule.lastDay;
        day++
      ) {
        final next = SummarySchedule.occurrencesAfter(
          DateTime(2026),
          day: day,
          count: 24,
        );

        expect(next, hasLength(24), reason: 'day $day lost a month');
        expect(
          next.map((d) => '${d.year}-${d.month}').toSet(),
          hasLength(24),
          reason: 'day $day fired twice in one month',
        );
      }
    });

    test('comes out in order', () {
      final next = SummarySchedule.occurrencesAfter(
        DateTime(2026, 8, 12),
        day: 31,
      );

      for (var i = 1; i < next.length; i++) {
        expect(next[i].isAfter(next[i - 1]), isTrue);
      }
    });
  });

  group('summarisedMonth', () {
    test('reports the month that has just finished', () {
      expect(
        SummarySchedule.summarisedMonth(DateTime(2026, 8, 1, 10)),
        DateTime(2026, 7),
      );
    });

    test('rolls back over the year', () {
      expect(
        SummarySchedule.summarisedMonth(DateTime(2026, 1, 15, 10)),
        DateTime(2025, 12),
      );
    });
  });

  test('every valid day is one the picker can offer', () {
    expect(SummarySchedule.isValidDay(0), isFalse);
    expect(SummarySchedule.isValidDay(1), isTrue);
    expect(SummarySchedule.isValidDay(31), isTrue);
    expect(SummarySchedule.isValidDay(32), isFalse);
  });
}
