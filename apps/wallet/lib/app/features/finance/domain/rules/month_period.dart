import 'package:meta/meta.dart';

/// A calendar month — the unit every total and budget in the app is measured
/// in.
///
/// Deliberately a calendar month rather than a configurable cycle (e.g. "from
/// payday to payday"): a custom cycle start would leak into every aggregation
/// and budget comparison, so it is a v2 decision, not a v1 default.
@immutable
class MonthPeriod implements Comparable<MonthPeriod> {
  const MonthPeriod(this.year, this.month);

  factory MonthPeriod.of(DateTime date) => MonthPeriod(date.year, date.month);

  final int year;

  /// 1-based, like [DateTime.month].
  final int month;

  /// First instant of the month, inclusive.
  DateTime get start => DateTime(year, month);

  /// First instant of the *next* month — the end is exclusive, which avoids
  /// the classic "last millisecond of the month" off-by-one.
  DateTime get end => DateTime(year, month + 1);

  /// `DateTime(2025, 13)` normalises to January 2026, so rollover is free.
  MonthPeriod get next => MonthPeriod.of(DateTime(year, month + 1));

  MonthPeriod get previous => MonthPeriod.of(DateTime(year, month - 1));

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);

  @override
  int compareTo(MonthPeriod other) => start.compareTo(other.start);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthPeriod && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'MonthPeriod($year-${month.toString().padLeft(2, '0')})';
}
