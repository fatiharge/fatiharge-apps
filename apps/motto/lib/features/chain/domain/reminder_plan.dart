import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/features/chain/domain/reminder_copy.dart';

/// Decides which reminders exist, and when.
///
/// Nothing here is conditional at delivery time: a scheduled notification
/// cannot check anything when it fires, so the whole plan is rebuilt whenever
/// the chain changes or the app opens.
abstract final class ReminderPlan {
  /// Long enough to survive a fortnight of not opening the app.
  static const horizonDays = 14;

  static const quietFrom = 22;
  static const quietUntil = 8;

  static const dayEndingHour = 21;

  static const milestones = [7, 21, 30];

  /// Someone ignoring three notifications is not someone who needs a fourth.
  static const fatigueThreshold = 3;

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
      if (!at.isAfter(now)) continue;

      final words = copy(kind, chain.streakOn(today));
      reminders.add(
        Reminder(kind: kind, at: at, title: words.title, body: words.body),
      );
    }

    return reminders
      ..addAll(_milestones(chain, today, now, hour, copy))
      ..sort((a, b) => a.at.compareTo(b.at));
  }

  /// At most one a day: the most informative wins, the rest are not sent.
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

    // Only today and tomorrow can be known to be broken. Further out every
    // unmarked day would read as a miss and fill the horizon with bad news
    // about days that have not happened.
    final tomorrow = today.add(const Duration(days: 1));
    if (isToday && chain.isBrokenOn(today) && !markedToday) {
      return ReminderKind.broken;
    }
    if (day == tomorrow && !markedToday) return ReminderKind.broken;

    if (_isFreezeRenewalDay(chain, day)) return ReminderKind.freezeRenewed;

    if (cooldownUntil != null && dayOf(cooldownUntil) == day) {
      return ReminderKind.mottoReady;
    }

    if (isToday && !markedToday && now.hour >= hour) {
      return ReminderKind.dayEnding;
    }

    if (isToday && markedToday) return null;

    if (_isSilencedByFatigue(day, today, unopenedInARow)) return null;

    return ReminderKind.daily;
  }

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

  /// Exempt from the one-a-day rule: a celebration landing on a day that
  /// already had a nudge is the point.
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
