import 'package:meta/meta.dart';

/// Why a reminder is being sent.
///
/// The kind decides the words and whether the quiet rules apply to it: a
/// milestone is a celebration and is allowed to arrive on a day that already
/// had its one reminder.
enum ReminderKind {
  /// The daily nudge, at the hour the person chose.
  daily,

  /// Late enough that the day is nearly gone, only when it is still unmarked.
  dayEnding,

  /// A day was missed. Carries the make-up offer with it — a separate
  /// notification for the offer would be a second interruption about the same
  /// bad news.
  broken,

  /// A new month, a new make-up.
  freezeRenewed,

  /// The cooldown ended and there is another motto to claim.
  mottoReady,

  /// 7, 21, 30. Exempt from the one-a-day rule.
  milestone;

  bool get isCelebration => this == ReminderKind.milestone;
}

/// One notification, decided before any plugin is involved.
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

  /// Set on a milestone, so the id is stable across reschedules.
  final int? streak;

  /// Stable within a plan, because scheduling starts by cancelling everything
  /// and a colliding id would silently drop one of two reminders.
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
