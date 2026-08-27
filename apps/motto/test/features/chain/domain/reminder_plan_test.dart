import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/features/chain/domain/reminder_plan.dart';

({String title, String body}) copy(ReminderKind kind, int streak) =>
    (title: kind.name, body: '$streak');

void main() {
  DateTime day(int d, [int hour = 9]) => DateTime(2026, 3, d, hour);

  Chain marked(List<int> days) => Chain(
    startedOn: DateTime(2026, 3, days.first),
    markedDays: {for (final d in days) DateTime(2026, 3, d)},
  );

  List<Reminder> plan({
    required Chain chain,
    required DateTime now,
    int hour = 9,
    int unopened = 0,
    DateTime? cooldownUntil,
  }) => ReminderPlan.build(
    chain: chain,
    now: now,
    hour: hour,
    copy: copy,
    unopenedInARow: unopened,
    cooldownUntil: cooldownUntil,
  );

  test('a chain that has not started sends nothing', () {
    expect(plan(chain: const Chain(), now: day(4)), isEmpty);
  });

  test('at most one reminder a day, milestones aside', () {
    final reminders = plan(chain: marked([1, 2, 3]), now: day(3, 10));

    final perDay = <DateTime, int>{};
    for (final reminder in reminders.where((r) => !r.kind.isCelebration)) {
      final key = dayOf(reminder.at);
      perDay[key] = (perDay[key] ?? 0) + 1;
    }
    expect(perDay.values, everyElement(1));
  });

  test('nothing arrives in the quiet hours', () {
    final reminders = plan(chain: marked([1]), now: day(1, 10), hour: 23);

    expect(
      reminders.every(
        (r) =>
            r.at.hour >= ReminderPlan.quietUntil &&
            r.at.hour < ReminderPlan.quietFrom,
      ),
      isTrue,
    );
  });

  test('an unmarked today past its hour gets the evening warning instead', () {
    final reminders = plan(chain: marked([1, 2]), now: day(3, 14));
    final today = reminders.firstWhere(
      (r) => dayOf(r.at) == DateTime(2026, 3, 3),
    );

    expect(today.kind, ReminderKind.dayEnding);
    expect(today.at.hour, ReminderPlan.dayEndingHour);
  });

  test('a marked today is left alone', () {
    final reminders = plan(chain: marked([1, 2, 3]), now: day(3, 10));

    expect(
      reminders.where((r) => dayOf(r.at) == DateTime(2026, 3, 3)),
      isEmpty,
    );
  });

  test('a broken chain says so, and the make-up rides along', () {
    final reminders = plan(chain: marked([1, 2]), now: day(5, 10));

    // One notification, not two: a separate offer would be a second
    // interruption about the same bad news.
    expect(reminders.first.kind, ReminderKind.broken);
  });

  test('three unopened in a row thins the daily reminder out', () {
    final busy = plan(chain: marked([1, 2, 3]), now: day(3, 10));
    final thinned = plan(
      chain: marked([1, 2, 3]),
      now: day(3, 10),
      unopened: ReminderPlan.fatigueThreshold,
    );

    expect(thinned.length, lessThan(busy.length));
  });

  test('milestones are scheduled and may share a day with a nudge', () {
    final reminders = plan(chain: marked([1, 2, 3]), now: day(3, 10));
    final milestone = reminders.firstWhere(
      (r) => r.kind == ReminderKind.milestone,
    );

    // Day 3 is marked, so the seventh is four days out.
    expect(milestone.streak, 7);
    expect(dayOf(milestone.at), DateTime(2026, 3, 7));
  });

  test('the cooldown ending is its own reminder', () {
    final reminders = plan(
      chain: marked([1, 2, 3]),
      now: day(3, 10),
      cooldownUntil: DateTime(2026, 3, 6),
    );

    expect(
      reminders.firstWhere((r) => dayOf(r.at) == DateTime(2026, 3, 6)).kind,
      ReminderKind.mottoReady,
    );
  });

  test('every reminder is in the future and inside the horizon', () {
    final now = day(3, 10);
    final reminders = plan(chain: marked([1, 2, 3]), now: now);

    expect(reminders.every((r) => r.at.isAfter(now)), isTrue);
    expect(
      reminders.every(
        (r) => r.at.difference(now).inDays <= ReminderPlan.horizonDays,
      ),
      isTrue,
    );
  });

  test('ids do not collide, or a reschedule would silently drop one', () {
    final reminders = plan(chain: marked([1, 2, 3]), now: day(3, 10));

    expect(
      reminders.map((r) => r.id).toSet(),
      hasLength(reminders.length),
    );
  });

  test('days that have not happened yet are not treated as missed', () {
    final reminders = plan(chain: marked([1, 2, 3]), now: day(3, 10));

    // Every future day is unmarked by definition. Reading that as a break
    // filled the whole fortnight with "you lost your chain".
    final later = reminders.where(
      (r) => r.at.isAfter(DateTime(2026, 3, 4, 23)) && !r.kind.isCelebration,
    );
    expect(later, isNotEmpty);
    expect(later.every((r) => r.kind == ReminderKind.daily), isTrue);
  });
}
