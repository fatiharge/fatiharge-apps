import 'package:meta/meta.dart';

/// A day, with the time thrown away — the chain is counted in local days.
DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// The same day, as the server reads it.
///
/// Written out here rather than left to the generated client: that one sends
/// `toUtc().toIso8601String()` for a query parameter, which the server cannot
/// parse and which has already moved the day for anyone east of UTC.
String isoDay(DateTime moment) {
  final day = dayOf(moment);
  final month = day.month.toString().padLeft(2, '0');
  final date = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$date';
}

/// What the chain is.
@immutable
class Chain {
  const Chain({
    this.startedOn,
    this.markedDays = const {},
    this.freezeUsedOn,
    this.period = 1,
    this.mottoId,
    this.periodDone = false,
  });

  final DateTime? startedOn;

  /// Normalised to midnight by [dayOf], so equality and lookup work.
  final Set<DateTime> markedDays;

  /// One a month. The difference between missing a day and losing the app.
  final DateTime? freezeUsedOn;

  /// Which run this is. [markedDays] is this run's days and no other's.
  final int period;

  /// Which of the archetype's mottos this run is under; null means the first.
  final String? mottoId;

  /// Fourteen days marked. The run is over.
  final bool periodDone;

  bool get started => startedOn != null;

  bool isMarked(DateTime day) => markedDays.contains(dayOf(day));

  /// A streak does not break at midnight, but when a whole day goes unmarked.
  int streakOn(DateTime today) {
    final day = dayOf(today);
    if (markedDays.isEmpty) return 0;

    var cursor = isMarked(day) ? day : day.subtract(const Duration(days: 1));
    if (!markedDays.contains(cursor)) return 0;

    var length = 0;
    while (markedDays.contains(cursor)) {
      length++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return length;
  }

  DateTime? get lastMarked {
    if (markedDays.isEmpty) return null;
    return markedDays.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Whole days missed before today. Today is not missed until it ends.
  int missedBefore(DateTime today) {
    final last = lastMarked;
    if (last == null) return 0;
    final gap = dayOf(today).difference(last).inDays - 1;
    return gap < 0 ? 0 : gap;
  }

  bool isBrokenOn(DateTime today) => started && missedBefore(today) > 0;

  /// A single missed day. Two is not a slip, and covering it would make the
  /// streak mean nothing.
  bool canFreezeOn(DateTime today) =>
      missedBefore(today) == 1 && !freezeSpentIn(today);

  /// Calendar month, so the month it renews in is predictable.
  bool freezeSpentIn(DateTime today) {
    final spent = freezeUsedOn;
    if (spent == null) return false;
    return spent.year == today.year && spent.month == today.month;
  }

  Chain start(DateTime today) => Chain(
    startedOn: dayOf(today),
    markedDays: {dayOf(today)},
    freezeUsedOn: freezeUsedOn,
  );

  Chain mark(DateTime today) => Chain(
    startedOn: startedOn ?? dayOf(today),
    markedDays: {...markedDays, dayOf(today)},
    freezeUsedOn: freezeUsedOn,
  );

  Chain freeze(DateTime today) {
    if (!canFreezeOn(today)) return this;
    return Chain(
      startedOn: startedOn,
      markedDays: {
        ...markedDays,
        dayOf(today).subtract(const Duration(days: 1)),
      },
      freezeUsedOn: dayOf(today),
    );
  }
}
