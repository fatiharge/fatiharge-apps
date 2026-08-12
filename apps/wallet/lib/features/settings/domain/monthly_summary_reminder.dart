import 'package:meta/meta.dart';

/// The user's answer to "shall we tell you when the month's summary is ready".
@immutable
class MonthlySummaryReminder {
  const MonthlySummaryReminder({required this.enabled, required this.day});

  /// Off, on the first of the month — the summary is only worth reading once
  /// the month it covers has finished.
  static const off = MonthlySummaryReminder(enabled: false, day: 1);

  final bool enabled;

  /// Day of the month, 1-31, as the user chose it. Months too short for it are
  /// handled when the dates are worked out, not by rejecting the choice here.
  final int day;

  MonthlySummaryReminder copyWith({bool? enabled, int? day}) =>
      MonthlySummaryReminder(
        enabled: enabled ?? this.enabled,
        day: day ?? this.day,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummaryReminder &&
          other.enabled == enabled &&
          other.day == day;

  @override
  int get hashCode => Object.hash(enabled, day);

  @override
  String toString() => 'MonthlySummaryReminder(enabled: $enabled, day: $day)';
}
