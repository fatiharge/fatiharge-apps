import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';

void main() {
  group('MonthPeriod', () {
    test('contains its own days and excludes the next month', () {
      const july = MonthPeriod(2026, 7);

      expect(july.contains(DateTime(2026, 7)), isTrue);
      expect(july.contains(DateTime(2026, 7, 31, 23, 59, 59)), isTrue);
      expect(july.contains(DateTime(2026, 8)), isFalse);
      expect(july.contains(DateTime(2026, 6, 30, 23, 59, 59)), isFalse);
    });

    test('rolls over the year boundary in both directions', () {
      expect(const MonthPeriod(2026, 12).next, const MonthPeriod(2027, 1));
      expect(const MonthPeriod(2026, 1).previous, const MonthPeriod(2025, 12));
    });

    test('February length comes from the calendar, not a constant', () {
      const leapFeb = MonthPeriod(2028, 2);
      expect(leapFeb.contains(DateTime(2028, 2, 29)), isTrue);

      const normalFeb = MonthPeriod(2026, 2);
      // 2026-02-29 does not exist; DateTime normalises it to March 1st.
      expect(normalFeb.contains(DateTime(2026, 2, 29)), isFalse);
    });

    test('value equality lets it be used as a map key', () {
      final seen = <MonthPeriod, int>{const MonthPeriod(2026, 7): 1};
      expect(seen[MonthPeriod.of(DateTime(2026, 7, 20))], 1);
    });
  });
}
