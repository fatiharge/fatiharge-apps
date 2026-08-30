import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/tasks/application/task_store.dart';

/// The day's three things, from the server or from the last time it answered.
///
/// Modelled on the chain, which has worked this way since it moved off the
/// phone: the cache is so the screen has something to draw, and the queue is so
/// a thing somebody did on a plane is not a thing they did for nothing.
@lazySingleton
class TaskRepository {
  TaskRepository(this._tasks, this._store);

  final api.TaskResourceApi _tasks;
  final TaskStore _store;

  ({int day, List<api.DailyTask> tasks})? get cached => _store.readCached();

  /// The server's answer, or the cache when it cannot be reached.
  Future<({int day, List<api.DailyTask> tasks})> load(DateTime today) async {
    await flushPending(today);

    final answered = await _tasks.dailyTasks(today: isoDay(today));
    final day = (
      day: answered?.day ?? 1,
      tasks: answered?.tasks ?? const <api.DailyTask>[],
    );
    await _store.cache(day.day, day.tasks);
    return day;
  }

  /// Ticks it, and keeps it when the server cannot be told yet.
  Future<void> complete(api.DailyTask task, DateTime today) async {
    try {
      await _tasks.completeTask(task.id, today: isoDay(today));
      await _store.clearTick(task.id);
    } on Object {
      // Queued and written into the cache at once, so the box stays ticked
      // through a restart rather than only until the next rebuild.
      await _store.queueTick(task.id);
      await _cacheTicked(task.id);
      rethrow;
    }
  }

  /// Replays what was ticked offline. Anything the server refuses is dropped:
  /// a tick it will not take today it will not take tomorrow either.
  Future<void> flushPending(DateTime today) async {
    for (final id in _store.pendingTicks()) {
      try {
        await _tasks.completeTask(id, today: isoDay(today));
        await _store.clearTick(id);
      } on api.ApiException {
        await _store.clearTick(id);
      } on Object {
        return;
      }
    }
  }

  Future<void> _cacheTicked(int taskId) async {
    final held = _store.readCached();
    if (held == null) return;

    await _store.cache(held.day, [
      for (final task in held.tasks)
        if (task.id == taskId)
          api.DailyTask(
            id: task.id,
            ordinal: task.ordinal,
            title: task.title,
            detail: task.detail,
            done: true,
          )
        else
          task,
    ]);
  }
}
