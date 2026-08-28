import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';

class _MockTasks extends Mock implements api.TaskResourceApi {}

api.DailyTask task(int ordinal, {bool done = false}) => api.DailyTask(
  id: ordinal,
  ordinal: ordinal,
  title: 'görev $ordinal',
  detail: 'ne yapılacağı',
  done: done,
);

void main() {
  late _MockTasks tasks;
  late TaskCubit cubit;

  setUpAll(() => registerFallbackValue('2026-03-03'));

  setUp(() {
    tasks = _MockTasks();
    when(() => tasks.dailyTasks(today: any(named: 'today'))).thenAnswer(
      (_) async => api.DailyTasks(day: 3, tasks: [task(1), task(2), task(3)]),
    );
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenAnswer((_) async => null);
    cubit = TaskCubit(tasks)..now = () => DateTime(2026, 3, 3, 10);
  });

  test('a day asks for three things', () async {
    await cubit.load();

    expect(cubit.state.status, TaskStatus.ready);
    expect(cubit.state.day, 3);
    expect(cubit.state.tasks, hasLength(3));
  });

  test('the date it sends is a day, not a moment', () async {
    await cubit.load();

    // Sent as a plain day. The generated client turns a DateTime into
    // `toUtc().toIso8601String()`, which the server cannot parse and which has
    // already moved the day for anyone east of UTC.
    final sent =
        verify(
              () => tasks.dailyTasks(today: captureAny(named: 'today')),
            ).captured.single
            as String;
    expect(sent, '2026-03-03');
  });

  test('ticking answers before the server does', () async {
    await cubit.load();
    final first = cubit.state.tasks.first;

    final pending = cubit.complete(first);

    // The point of a checkbox is that it answers instantly.
    expect(cubit.state.tasks.first.done, isTrue);
    expect(cubit.state.done, 1);
    await pending;
  });

  test('ticking one already done asks the server nothing', () async {
    when(() => tasks.dailyTasks(today: any(named: 'today'))).thenAnswer(
      (_) async => api.DailyTasks(day: 1, tasks: [task(1, done: true)]),
    );
    await cubit.load();

    await cubit.complete(cubit.state.tasks.first);

    verifyNever(() => tasks.completeTask(any(), today: any(named: 'today')));
  });

  test('a refused tick is taken back rather than left showing', () async {
    await cubit.load();
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenThrow(Exception('offline'));

    await cubit.complete(cubit.state.tasks.first);

    // Reloaded from the server, which never heard about it.
    expect(cubit.state.tasks.first.done, isFalse);
  });

  test('a day that cannot be fetched says so', () async {
    when(
      () => tasks.dailyTasks(today: any(named: 'today')),
    ).thenThrow(Exception('offline'));

    await cubit.load();

    expect(cubit.state.status, TaskStatus.failed);
  });
}
