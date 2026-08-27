import 'package:meta/meta.dart';

/// A day, with the time thrown away.
///
/// The chain is counted in local days, not in hours: someone who marks at
/// 23:59 and again at 00:01 has marked two days, and someone who marks twice
/// in an afternoon has marked one.
DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// What the chain is, kept on the device and nowhere else.
///
/// There is no account to attach it to and nothing here is worth a round trip:
/// the streak is the person's, not a record we need.
@immutable
class Chain {
  const Chain({this.startedOn, this.markedDays = const {}, this.freezeUsedOn});

  final DateTime? startedOn;

  /// Normalised to midnight by [dayOf], so equality and lookup work.
  final Set<DateTime> markedDays;

  /// When the make-up was last spent. One a month, and it is the difference
  /// between missing a day and losing everything — a broken chain is what
  /// makes people delete the app.
  final DateTime? freezeUsedOn;

  bool get started => startedOn != null;

  bool isMarked(DateTime day) => markedDays.contains(dayOf(day));

  /// Consecutive days ending today, or ending yesterday when today is still
  /// open. A streak does not break at midnight; it breaks when a whole day
  /// goes by unmarked.
  int streakOn(DateTime today) {
    final day = dayOf(today);
    if (markedDays.isEmpty) return 0;

    // Counting starts from yesterday when today is unmarked, so an unfinished
    // today does not read as a loss.
    var cursor = isMarked(day) ? day : day.subtract(const Duration(days: 1));
    if (!markedDays.contains(cursor)) return 0;

    var length = 0;
    while (markedDays.contains(cursor)) {
      length++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return length;
  }

  /// The last day that was marked, or null before the first one.
  DateTime? get lastMarked {
    if (markedDays.isEmpty) return null;
    return markedDays.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// How many whole days were missed before today. Zero while the chain is
  /// intact — including today, which is not missed until it ends.
  int missedBefore(DateTime today) {
    final last = lastMarked;
    if (last == null) return 0;
    final gap = dayOf(today).difference(last).inDays - 1;
    return gap < 0 ? 0 : gap;
  }

  bool isBrokenOn(DateTime today) => started && missedBefore(today) > 0;

  /// The make-up covers a single missed day. Two days gone is not a slip, and
  /// pretending otherwise would make the streak mean nothing.
  bool canFreezeOn(DateTime today) =>
      missedBefore(today) == 1 && !freezeSpentIn(today);

  /// One per calendar month, so the month it renews in is predictable.
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

  /// Fills the one missed day and spends the month's make-up.
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
