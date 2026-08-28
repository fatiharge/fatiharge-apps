import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/tasks/presentation/period_report_page.dart';
import 'package:motto/features/tasks/presentation/task_detail_page.dart';

class _MockTasks extends Mock implements api.TaskResourceApi {}

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
}
