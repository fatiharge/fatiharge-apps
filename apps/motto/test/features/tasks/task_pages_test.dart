import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/game/application/turns_cubit.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/features/tasks/presentation/daily_tasks_page.dart';
import 'package:motto/features/tasks/presentation/period_report_page.dart';
import 'package:motto/features/tasks/presentation/task_detail_page.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockTasks extends Mock implements api.TaskResourceApi {}

class _MockChains extends Mock implements ChainRepository {}

class _MockScheduler extends Mock implements ReminderScheduler {}

class _MockEvents extends Mock implements api.EventResourceApi {}

class _MockTurns extends Mock implements api.PlayResourceApi {}

api.DailyTask task({bool done = false}) => api.DailyTask(
  id: 1,
  ordinal: 1,
  title: 'Bir dakikanı seç',
  detail: 'Bugün yapacağın şeyi seç.',
  done: done,
);

void main() {
  group('the task detail', () {
    testWidgets('says what the task is and why', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: TaskDetailPage(task: task(), day: 3)),
      );

      // A task with nowhere to read it is a checkbox, and a checkbox is not a
      // reason to open an app.
      expect(find.text('Bir dakikanı seç'), findsOneWidget);
      expect(find.text('Bugün yapacağın şeyi seç.'), findsOneWidget);
      expect(find.text('3. gün'), findsOneWidget);
    });

    testWidgets('offers the button only while it is undone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: TaskDetailPage(task: task(done: true), day: 1)),
      );

      expect(find.text('Yaptım'), findsNothing);
      expect(find.text('Yapıldı'), findsOneWidget);
    });

    testWidgets('holds the button back until the chain starts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: TaskDetailPage(task: task(), day: 1)),
      );

      // Without a chain there is nothing to record against, and a button that
      // pops without recording reads as though the tap counted.
      expect(find.text('Yaptım'), findsNothing);
      expect(
        find.text('Zincirini başlattığında işaretlenmeye açılıyor.'),
        findsOneWidget,
      );
    });

    testWidgets('ticking it off reports back', (tester) async {
      var ticked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: task(),
            day: 1,
            onDone: () async => ticked = true,
          ),
        ),
      );

      await tester.tap(find.text('Yaptım'));
      await tester.pump();

      expect(ticked, isTrue);
    });
  });

  group('the period report', () {
    late _MockTasks tasks;

    setUp(() {
      tasks = _MockTasks();
      getIt.registerSingleton<api.TaskResourceApi>(tasks);
    });

    tearDown(getIt.reset);

    testWidgets('counts made-up days apart from marked ones', (tester) async {
      when(() => tasks.periodReport(today: any(named: 'today'))).thenAnswer(
        (_) async => api.PeriodReport(
          day: 5,
          daysMarked: 5,
          daysMadeUp: 1,
          tasksDone: 9,
          tasksOffered: 15,
          complete: false,
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: PeriodReportPage()));
      await tester.pumpAndSettle();

      // A report that counts them as the same thing is flattering rather than
      // useful.
      expect(find.text('5. gündesin'), findsOneWidget);
      expect(find.text('5 / 14'), findsOneWidget);
      expect(find.text('9 / 15'), findsOneWidget);
      expect(find.text('Bunların telafiyle gelen'), findsOneWidget);
    });

    testWidgets('says nothing about make-ups when there were none', (
      tester,
    ) async {
      when(() => tasks.periodReport(today: any(named: 'today'))).thenAnswer(
        (_) async => api.PeriodReport(
          day: 14,
          daysMarked: 14,
          daysMadeUp: 0,
          tasksDone: 40,
          tasksOffered: 42,
          complete: true,
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: PeriodReportPage()));
      await tester.pumpAndSettle();

      expect(find.text('On dört gün bitti'), findsOneWidget);
      expect(find.text('Bunların telafiyle gelen'), findsNothing);
    });

    testWidgets('a report that cannot be fetched says so', (tester) async {
      when(
        () => tasks.periodReport(today: any(named: 'today')),
      ).thenThrow(Exception('offline'));

      await tester.pumpWidget(const MaterialApp(home: PeriodReportPage()));
      await tester.pumpAndSettle();

      expect(find.text('Rapor alınamadı.'), findsOneWidget);
    });
  });

  group("the day's three things", () {
    late _MockTasks tasks;

    setUpAll(() => registerFallbackValue(api.EventBatch()));

    setUp(() async {
      tasks = _MockTasks();
      when(() => tasks.dailyTasks(today: any(named: 'today'))).thenAnswer(
        (_) async => api.DailyTasks(
          day: 3,
          tasks: [task(), task(done: true)],
        ),
      );
      when(
        () => tasks.completeTask(any(), today: any(named: 'today')),
      ).thenAnswer((_) async => null);
      getIt.registerFactory<TaskCubit>(() => TaskCubit(tasks));

      // The run sits above the three things now, so the screen needs one.
      SharedPreferences.setMockInitialValues({});
      final chains = _MockChains();
      when(() => chains.cached).thenReturn(const Chain());
      when(() => chains.load(any())).thenAnswer((_) async => const Chain());
      final events = _MockEvents();
      when(() => events.recordEvents(any())).thenAnswer(
        (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
      );
      final preferences = await SharedPreferences.getInstance();
      getIt.registerFactory<ChainCubit>(
        () => ChainCubit(
          chains,
          ChainStore(preferences),
          _MockScheduler(),
          Analytics(EventQueue(preferences), events),
        ),
      );

      // The turn card reads this: no turn, no card.
      final turns = _MockTurns();
      when(() => turns.gameTurns(today: any(named: 'today'))).thenAnswer(
        (_) async => api.PlayCredits(
          remaining: 0,
          earned: 0,
          spent: 0,
          dayMarked: false,
          tasksDone: false,
        ),
      );
      getIt.registerFactory<TurnsCubit>(
        () => TurnsCubit(TurnsRepository(turns)),
      );
    });

    tearDown(getIt.reset);

    /// The cubits live on the shell now, so the page reads them from above
    /// rather than building its own. A test that pumps it bare is testing a
    /// page the app never shows.
    Widget hosted() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TaskCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<TurnsCubit>()..unawaitedLoad()),
      ],
      child: const MaterialApp(home: DailyTasksPage()),
    );

    testWidgets('they get a screen of their own', (tester) async {
      await tester.pumpWidget(hosted());
      await tester.pumpAndSettle();

      // Three checkboxes squeezed between two blocks of text is a list nobody
      // reads.
      expect(find.text('Bir dakikanı seç'), findsNWidgets(2));
      expect(find.byType(Checkbox), findsNWidgets(2));

      // The run sits above them, because it is what they are for.
      expect(find.text('ZİNCİR'), findsOneWidget);
      expect(find.textContaining('/ 14'), findsOneWidget);
      expect(find.text('Görevler'), findsOneWidget);
      expect(find.textContaining('BUGÜNÜN ÜÇ ŞEYİ'), findsOneWidget);

      // And the button that closes the day sits under them, not over them.
      expect(find.text('Zincirini başlat'), findsOneWidget);
    });

    testWidgets('before the chain starts the boxes do not take a tick', (
      tester,
    ) async {
      await tester.pumpWidget(hosted());
      await tester.pumpAndSettle();

      // Ticking here used to record the work against no chain at all: the
      // screen said three of three done and the run said it had not started.
      final box = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(box.onChanged, isNull);
      expect(
        find.textContaining('Zincirini başlattığında'),
        findsOneWidget,
      );
    });

    testWidgets('the button says it is about to ask for an hour', (
      tester,
    ) async {
      await tester.pumpWidget(hosted());
      await tester.pumpAndSettle();

      // A button that opens a clock nobody expected is a button people cancel.
      expect(find.text('Hatırlatma saatini soracağım.'), findsOneWidget);
    });

    testWidgets('a day that cannot be fetched says so, and is reported', (
      tester,
    ) async {
      when(
        () => tasks.dailyTasks(today: any(named: 'today')),
      ).thenThrow(Exception('offline'));

      await tester.pumpWidget(hosted());
      await tester.pumpAndSettle();

      // An empty list and a failed request looked identical, which is how a
      // broken endpoint hid for a whole feature.
      expect(find.textContaining('alınamadı'), findsOneWidget);

      // And it does not disappear quietly: a screen that says "alınamadı" over
      // a silent log is a day of guessing for whoever has to fix it.
      final reported = tester.takeException();
      expect(reported, isA<Exception>());
    });
  });
}
