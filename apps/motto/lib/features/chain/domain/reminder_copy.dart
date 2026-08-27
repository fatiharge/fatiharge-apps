import 'package:motto/features/chain/domain/reminder.dart';

/// A function rather than strings on the planner: the planner decides *when*,
/// and a test of that should not care what the sentence says.
typedef ReminderCopy =
    ({String title, String body}) Function(
      ReminderKind kind,
      int streak,
    );
