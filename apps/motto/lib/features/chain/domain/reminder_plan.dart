import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/features/chain/domain/reminder_copy.dart';

/// Decides which reminders exist, and when.
///
/// Pure, and deliberately so: every rule below is something someone will want
/// to argue about later, and arguing is cheaper against a test than against a
/// phone that has to wait until 21:00 to disagree.
///
/// Nothing here is conditional at delivery time, because a scheduled
/// notification cannot check anything when it fires. Correctness comes from
/// rescheduling instead: the whole plan is cancelled and rebuilt whenever the
/// chain changes or the app opens.
abstract final class ReminderPlan {
  /// How far ahead to schedule. Long enough to survive a fortnight of not
  /// opening the app, short enough that the rebuilt plan is small.
  static const horizonDays = 14;

  /// Nothing arrives between these hours.
  static const quietFrom = 22;
  static const quietUntil = 8;

  /// The evening warning, for a day that is nearly gone and still unmarked.
  static const dayEndingHour = 21;

  static const milestones = [7, 21, 30];

  /// After this many reminders in a row that nobody opened, the daily one
  /// stops being daily. Someone ignoring three notifications is not someone
  /// who needs a fourth.
  static const fatigueThreshold = 3;

  /// How often the daily reminder arrives once fatigue has set in.
  static const fatigueEveryDays = 3;

  static List<Reminder> build({
    required Chain chain,
    required DateTime now,
    required int hour,
    required ReminderCopy copy,
    int unopenedInARow = 0,
    DateTime? cooldownUntil,
  }) {
    if (!chain.started) return const [];

    final today = dayOf(now);
    final reminders = <Reminder>[];

    for (var offset = 0; offset < horizonDays; offset++) {
      final day = today.add(Duration(days: offset));
      final kind = _kindFor(
        chain: chain,
        today: today,
        day: day,
        now: now,
        hour: hour,
        cooldownUntil: cooldownUntil,
        unopenedInARow: unopenedInARow,
      );
      if (kind == null) continue;

      final at = _wake(
        DateTime(
          day.year,
          day.month,
          day.day,
          kind == ReminderKind.dayEnding ? dayEndingHour : hour,
        ),
      );
      // A slot the day has already passed cannot be scheduled, only missed.
      if (!at.isAfter(now)) continue;

      // The streak as it stands today, not as it would be on that day: the
      // number a person recognises is the one they last saw.
      final words = copy(kind, chain.streakOn(today));
      reminders.add(
        Reminder(kind: kind, at: at, title: words.title, body: words.body),
      );
    }

    return reminders
      ..addAll(_milestones(chain, today, now, hour, copy))
      ..sort((a, b) => a.at.compareTo(b.at));
  }

  /// At most one per day, so the priority here is the whole of the one-a-day
  /// rule: the most informative thing wins and the rest are simply not sent.
  static ReminderKind? _kindFor({
    required Chain chain,
    required DateTime today,
    required DateTime day,
    required DateTime now,
    required int hour,
    required int unopenedInARow,
    DateTime? cooldownUntil,
  }) {
    final isToday = day == today;
    final markedToday = chain.isMarked(today);

    // Only today and the next morning can be known to be broken. Further out
    // the chain is assumed intact — every unmarked future day would otherwise
    // read as a miss, and the horizon would fill with bad news about days that
    // have not happened. The plan is rebuilt the moment that stops being true.
    final tomorrow = today.add(const Duration(days: 1));
    if (isToday && chain.isBrokenOn(today) && !markedToday) {
      return ReminderKind.broken;
    }
    if (day == tomorrow && !markedToday) return ReminderKind.broken;

    if (_isFreezeRenewalDay(chain, day)) return ReminderKind.freezeRenewed;

    if (cooldownUntil != null && dayOf(cooldownUntil) == day) {
      return ReminderKind.mottoReady;
    }

    // Today's own reminder hour has gone by unmarked; the evening warning is
    // what is left of the day.
    if (isToday && !markedToday && now.hour >= hour) {
      return ReminderKind.dayEnding;
    }

    if (isToday && markedToday) return null;

    if (_isSilencedByFatigue(day, today, unopenedInARow)) return null;

    return ReminderKind.daily;
  }

  /// The month after the one the make-up was spent in, on its first day.
  static bool _isFreezeRenewalDay(Chain chain, DateTime day) {
    final spent = chain.freezeUsedOn;
    if (spent == null || day.day != 1) return false;
    final renewal = DateTime(spent.year, spent.month + 1);
    return day == renewal;
  }

  static bool _isSilencedByFatigue(DateTime day, DateTime today, int unopened) {
    if (unopened < fatigueThreshold) return false;
    return day.difference(today).inDays % fatigueEveryDays != 0;
  }

  /// Only the milestones still ahead, and only if the chain reaches them
  /// inside the horizon. They are exempt from the one-a-day rule: a
  /// celebration landing on a day that already had a nudge is the point.
  static List<Reminder> _milestones(
    Chain chain,
    DateTime today,
    DateTime now,
    int hour,
    ReminderCopy copy,
  ) {
    final reached = chain.streakOn(today) + (chain.isMarked(today) ? 0 : 1);
    final result = <Reminder>[];

    for (final target in milestones) {
      final daysAway = target - reached;
      if (daysAway < 0 || daysAway >= horizonDays) continue;

      final at = _wake(
        DateTime(
          today.year,
          today.month,
          today.day,
          hour,
        ).add(Duration(days: daysAway)),
      );
      if (!at.isAfter(now)) continue;

      final words = copy(ReminderKind.milestone, target);
      result.add(
        Reminder(
          kind: ReminderKind.milestone,
          at: at,
          title: words.title,
          body: words.body,
          streak: target,
        ),
      );
    }
    return result;
  }

  /// Moves anything landing in the quiet hours to the start of the next waking
  /// one. Late enough at night and it is tomorrow's problem, literally.
  static DateTime _wake(DateTime at) {
    if (at.hour >= quietFrom) {
      final next = at.add(const Duration(days: 1));
      return DateTime(next.year, next.month, next.day, quietUntil);
    }
    if (at.hour < quietUntil) {
      return DateTime(at.year, at.month, at.day, quietUntil);
    }
    return at;
  }
}
