import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted, because the interesting moments are the ones most likely to
/// happen without a network: someone shares the card and closes the app.
@lazySingleton
class EventQueue {
  EventQueue(this._preferences);

  static const _key = 'analytics_queue';

  /// Past this the network has been gone a long time; the oldest go first.
  static const capacity = 500;

  final SharedPreferences _preferences;

  List<Map<String, Object?>> read() {
    final stored = _preferences.getString(_key);
    if (stored == null) return [];

    // Dropping an unparseable queue loses some counts; keeping it loses all
    // of them, plus the ones that have not happened yet.
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      return [
        for (final entry in decoded) (entry as Map<String, dynamic>).cast(),
      ];
    } on FormatException {
      return [];
    }
  }

  Future<void> add(Map<String, Object?> entry) async {
    final entries = read()..add(entry);
    await _write(entries);
  }

  Future<void> removeFirst(int count) async {
    final entries = read();
    await _write(entries.sublist(count.clamp(0, entries.length)));
  }

  Future<void> _write(List<Map<String, Object?>> entries) {
    final kept = entries.length <= capacity
        ? entries
        : entries.sublist(entries.length - capacity);
    return _preferences.setString(_key, jsonEncode(kept));
  }
}
