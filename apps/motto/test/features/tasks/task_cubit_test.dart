import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/features/tasks/application/task_repository.dart';
import 'package:motto/features/tasks/application/task_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tasks = _MockTasks();
    when(() => tasks.dailyTasks(today: any(named: 'today'))).thenAnswer(
      (_) async => api.DailyTasks(day: 3, tasks: [task(1), task(2), task(3)]),
    );
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenAnswer((_) async => null);
    cubit = TaskCubit(
      TaskRepository(tasks, TaskStore(await SharedPreferences.getInstance())),
    )..now = () => DateTime(2026, 3, 3, 10);
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

  test('a tick the server never heard stays where it was put', () async {
    await cubit.load();
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenThrow(Exception('offline'));

    await cubit.complete(cubit.state.tasks.first);

    // It used to untick itself. Somebody who ticked it on a plane, looked away
    // and looked back read that as the app losing their work — and the day
    // they had actually done did not count.
    expect(cubit.state.tasks.first.done, isTrue);
  });

  test('and is sent the next time the server can be reached', () async {
    await cubit.load();
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenThrow(Exception('offline'));
    await cubit.complete(cubit.state.tasks.first);

    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenAnswer((_) async => null);
    await cubit.load();

    // The chain has drained its queue this way since it moved to the server.
    verify(() => tasks.completeTask(1, today: any(named: 'today'))).called(2);
  });

  test(
    'a day already on the phone is drawn before the server answers',
    () async {
      await cubit.load();
      when(
        () => tasks.dailyTasks(today: any(named: 'today')),
      ).thenThrow(Exception('offline'));

      await cubit.load();

      // Bugün works on a plane because the package is on the phone. Görevler is
      // the tab somebody opens the app to use, and it was the one that went
      // blank.
      expect(cubit.state.status, TaskStatus.ready);
      expect(cubit.state.tasks, hasLength(3));
    },
  );

  test('a day that cannot be fetched says so', () async {
    when(
      () => tasks.dailyTasks(today: any(named: 'today')),
    ).thenThrow(Exception('offline'));

    await cubit.load();

    expect(cubit.state.status, TaskStatus.failed);
  });

  test('a dead session does not throw away the tick it was carrying', () async {
    await cubit.load();
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenThrow(Exception('offline'));
    await cubit.complete(cubit.state.tasks.first);

    // The first request out of the door when the wifi comes back can answer
    // 401 while the token is being renewed. Reading that as "the server does
    // not want this tick" threw away work somebody did on a plane.
    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenThrow(api.ApiException(401, ''));
    await cubit.load();

    when(
      () => tasks.completeTask(any(), today: any(named: 'today')),
    ).thenAnswer((_) async => null);
    await cubit.load();

    verify(() => tasks.completeTask(1, today: any(named: 'today'))).called(3);
  });
}
