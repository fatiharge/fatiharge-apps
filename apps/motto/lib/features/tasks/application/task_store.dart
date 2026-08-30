import 'dart:convert';

import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The day's three things as the phone last saw them, and the ticks it has not
/// managed to send yet.
///
/// The chain has had both of these since it moved to the server. The tasks
/// never did, so an aeroplane left Bugün working and Görevler empty — the tab
/// somebody opens the app to use.
@lazySingleton
class TaskStore {
  TaskStore(this._preferences);

  static const _cacheKey = 'tasks_cache';
  static const _queueKey = 'tasks_pending_ticks';

  final SharedPreferences _preferences;

  /// Null when this phone has never seen a day's tasks.
  ({int day, List<api.DailyTask> tasks})? readCached() {
    final stored = _preferences.getString(_cacheKey);
    if (stored == null) return null;

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return (
        day: decoded['day'] as int,
        tasks: [
          for (final task in decoded['tasks'] as List<dynamic>)
            _task(task as Map<String, dynamic>),
        ],
      );
    } on Object {
      // A cache that will not parse would not parse on the next launch either.
      return null;
    }
  }

  Future<void> cache(int day, List<api.DailyTask> tasks) =>
      _preferences.setString(
        _cacheKey,
        jsonEncode({
          'day': day,
          'tasks': [
            for (final task in tasks)
              {
                'id': task.id,
                'ordinal': task.ordinal,
                'title': task.title,
                'detail': task.detail,
                'done': task.done,
              },
          ],
        }),
      );

  /// Ticks made while the server could not be reached.
  List<int> pendingTicks() {
    final stored = _preferences.getStringList(_queueKey) ?? const <String>[];
    return [for (final id in stored) int.parse(id)];
  }

  Future<void> queueTick(int taskId) async {
    final pending = {...pendingTicks(), taskId}.map((id) => '$id').toList();
    await _preferences.setStringList(_queueKey, pending);
  }

  Future<void> clearTick(int taskId) async {
    final pending = pendingTicks().where((id) => id != taskId);
    await _preferences.setStringList(
      _queueKey,
      [for (final id in pending) '$id'],
    );
  }

  static api.DailyTask _task(Map<String, dynamic> json) => api.DailyTask(
    id: json['id'] as int,
    ordinal: json['ordinal'] as int,
    title: json['title'] as String,
    detail: json['detail'] as String,
    done: json['done'] as bool,
  );
}
