import 'dart:async';
import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/features/chain/domain/chain.dart';

enum TaskStatus { loading, ready, failed }

@immutable
class TaskState {
  const TaskState({
    this.status = TaskStatus.loading,
    this.day = 1,
    this.tasks = const [],
    this.justFinished = false,
  });

  final TaskStatus status;
  final int day;
  final List<api.DailyTask> tasks;

  /// True for the one rebuild that follows the third tick. The screen owns
  /// where that leads; a cubit that pushes routes cannot be tested without a
  /// router and starts deciding what the app looks like.
  final bool justFinished;

  int get done => tasks.where((task) => task.done).length;

  TaskState copyWith({
    TaskStatus? status,
    int? day,
    List<api.DailyTask>? tasks,
    bool justFinished = false,
  }) => TaskState(
    status: status ?? this.status,
    day: day ?? this.day,
    tasks: tasks ?? this.tasks,
    justFinished: justFinished,
  );
}

@injectable
class TaskCubit extends Cubit<TaskState> {
  TaskCubit(this._tasks) : super(const TaskState());

  final api.TaskResourceApi _tasks;

  @visibleForTesting
  DateTime Function() now = DateTime.now;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    try {
      final today = await _tasks.dailyTasks(today: isoDay(now()));
      emit(
        TaskState(
          status: TaskStatus.ready,
          day: today?.day ?? 1,
          tasks: today?.tasks ?? const [],
        ),
      );
    } on Object catch (failure, trace) {
      reported('tasks', failure, trace);
      emit(state.copyWith(status: TaskStatus.failed));
    }
  }

  /// Ticked here before the server hears about it: the point of a checkbox is
  /// that it answers instantly, and the server refusing is not a case anyone
  /// can act on.
  Future<void> complete(api.DailyTask task) async {
    if (task.done) return;

    final ticked = [
      for (final each in state.tasks)
        if (each.id == task.id)
          api.DailyTask(
            id: each.id,
            ordinal: each.ordinal,
            title: each.title,
            detail: each.detail,
            done: true,
          )
        else
          each,
    ];

    emit(
      state.copyWith(
        tasks: ticked,
        // Only on the tick that finishes them. A day that is already done and
        // then reloaded is not a day somebody just finished.
        justFinished: ticked.isNotEmpty && ticked.every((each) => each.done),
      ),
    );

    try {
      await _tasks.completeTask(task.id, today: isoDay(now()));
    } on Object catch (failure, trace) {
      reported('tasks', failure, trace);
      await load();
    }
  }
}
