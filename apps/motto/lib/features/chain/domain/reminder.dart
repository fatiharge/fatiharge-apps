import 'package:meta/meta.dart';

/// Why a reminder is being sent. A milestone is exempt from the one-a-day
/// rule; the rest are not.
enum ReminderKind {
  daily,
  dayEnding,

  /// A day was missed. Carries the make-up offer, because a second
  /// notification about the same bad news is a second interruption.
  broken,
  freezeRenewed,
  mottoReady,
  milestone;

  bool get isCelebration => this == ReminderKind.milestone;
}

@immutable
class Reminder {
  const Reminder({
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    this.streak,
  });

  final ReminderKind kind;
  final DateTime at;
  final String title;
  final String body;

  final int? streak;

  /// A colliding id would silently drop one of two reminders.
  int get id =>
      Object.hash(kind, at.year, at.month, at.day, at.hour) & 0x7fffffff;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.kind == kind &&
      other.at == at &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(kind, at, title, body);

  @override
  String toString() => '$kind at $at';
}
