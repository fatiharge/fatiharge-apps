/// The day is clamped per month: a repeat set to the 31st never fires in
/// February, so the user would silently stop hearing from the app. Clamping
/// leaves no single repeating rule, which is why occurrences are enumerated.
abstract final class SummarySchedule {
  static const int firstDay = 1;
  static const int lastDay = 31;

  /// Fixed rather than asked: one more question in the flow costs more than
  /// it buys.
  static const int hour = 10;

  static bool isValidDay(int day) => day >= firstDay && day <= lastDay;

  /// Reschedule on launch to keep the window rolling.
  static List<DateTime> occurrencesAfter(
    DateTime from, {
    required int day,
    int count = 12,
  }) {
    final occurrences = <DateTime>[];
    var year = from.year;
    var month = from.month;

    while (occurrences.length < count) {
      final candidate = DateTime(year, month, _clamp(day, year, month), hour);
      if (candidate.isAfter(from)) occurrences.add(candidate);

      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    return occurrences;
  }

  /// A reminder on any day of August reports July: the month it covers has to
  /// have finished.
  static DateTime summarisedMonth(DateTime firesAt) =>
      DateTime(firesAt.year, firesAt.month - 1);

  static int _clamp(int day, int year, int month) {
    // Day zero of the next month is the last day of this one — no table of
    // month lengths, and leap years come out right.
    final lastOfMonth = DateTime(year, month + 1, 0).day;
    return day < lastOfMonth ? day : lastOfMonth;
  }
}
