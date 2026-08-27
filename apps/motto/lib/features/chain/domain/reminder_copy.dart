import 'package:motto/features/chain/domain/reminder.dart';

/// The words a reminder is sent with.
///
/// A function rather than strings on the planner: the planner decides *when*
/// and *whether*, and a test of that should not have to care what the sentence
/// says. The app supplies one over the bundled copy.
///
/// The tone belongs in the copy, not here — the chain is waiting for you, never
/// how many days you have missed. A reminder that scolds gets the app deleted.
typedef ReminderCopy = ({String title, String body}) Function(
  ReminderKind kind,
  int streak,
);
