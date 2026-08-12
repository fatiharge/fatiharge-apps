/// When the monthly summary reminder should fire.
///
/// The day is clamped to the length of each month, which is the whole reason
/// this exists: `flutter_local_notifications` can repeat on a day-of-month,
/// but a repeat set to the 31st simply never fires in February — the user
/// picks a day and then silently stops hearing from the app. Clamping means
/// the 31st lands on the 28th, or the 29th in a leap year.
///
/// Because of that clamping there is no single repeating rule to hand the
/// platform, so occurrences are enumerated and rescheduled while the app is
/// open. [occurrencesAfter] is what produces them.
abstract final class SummarySchedule {
  /// Days the user may choose from. Any of them is safe — see the clamping.
  static const int firstDay = 1;
  static const int lastDay = 31;

  /// The hour a reminder arrives. Fixed rather than asked: one more question
  /// in the flow buys less than it costs, and mid-morning is late enough not
  /// to wake anyone and early enough not to be missed.
  static const int hour = 10;

  static bool isValidDay(int day) => day >= firstDay && day <= lastDay;

  /// The next [count] reminder times strictly after [from].
  ///
  /// Enumerated rather than repeated so the clamping above can apply per
  /// month. Reschedule on launch to keep the window rolling.
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

  /// The month a reminder is about: the one that has just finished.
  ///
  /// A summary of the month you are still living in is a guess, so a reminder
  /// on any day of August reports July.
  static DateTime summarisedMonth(DateTime firesAt) =>
      DateTime(firesAt.year, firesAt.month - 1);

  static int _clamp(int day, int year, int month) {
    // Day zero of the next month is the last day of this one, so this needs no
    // table of month lengths and gets leap years right on its own.
    final lastOfMonth = DateTime(year, month + 1, 0).day;
    return day < lastOfMonth ? day : lastOfMonth;
  }
}
