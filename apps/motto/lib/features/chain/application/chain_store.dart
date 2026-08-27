import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The phone's copy of what the server said, plus the marks it has not managed
/// to send yet.
///
/// The chain itself lives on the server now. This is a cache so the screen has
/// something to draw before the request comes back, and a queue so a day marked
/// on a plane is not a day lost.
@lazySingleton
class ChainStore {
  ChainStore(this._preferences);

  static const _cacheKey = 'chain_cache';
  static const _queueKey = 'chain_pending_marks';
  static const _hourKey = 'chain_reminder_hour';
  static const _unopenedKey = 'chain_unopened_in_a_row';

  /// What the picker opens on when the chain starts. The hour is asked for.
  static const defaultHour = 9;

  final SharedPreferences _preferences;

  Chain readCached() {
    final stored = _preferences.getString(_cacheKey);
    if (stored == null) return const Chain();

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return Chain(
        startedOn: _date(decoded['startedOn']),
        markedDays: {
          for (final day in decoded['markedDays'] as List<dynamic>)
            DateTime.parse(day as String),
        },
        freezeUsedOn: _date(decoded['freezeUsedOn']),
      );
    } on FormatException {
      return const Chain();
    }
  }

  Future<void> cache(Chain chain) => _preferences.setString(
    _cacheKey,
    jsonEncode({
      'startedOn': chain.startedOn?.toIso8601String(),
      'markedDays': [for (final day in chain.markedDays) day.toIso8601String()],
      'freezeUsedOn': chain.freezeUsedOn?.toIso8601String(),
    }),
  );

  /// Days marked while the server could not be reached, oldest first.
  List<DateTime> pendingMarks() {
    final stored = _preferences.getStringList(_queueKey) ?? const [];
    return [for (final day in stored) DateTime.parse(day)]..sort();
  }

  Future<void> queueMark(DateTime day) async {
    final pending = {...pendingMarks().map(_key), _key(day)}.toList()..sort();
    await _preferences.setStringList(_queueKey, pending);
  }

  Future<void> clearMark(DateTime day) async {
    final pending = pendingMarks().map(_key).toList()..remove(_key(day));
    await _preferences.setStringList(_queueKey, pending);
  }

  int get hour => _preferences.getInt(_hourKey) ?? defaultHour;

  Future<void> setHour(int hour) => _preferences.setInt(_hourKey, hour);

  int get unopenedInARow => _preferences.getInt(_unopenedKey) ?? 0;

  Future<void> countUnopened() =>
      _preferences.setInt(_unopenedKey, unopenedInARow + 1);

  Future<void> resetUnopened() => _preferences.setInt(_unopenedKey, 0);

  static String _key(DateTime day) =>
      dayOf(day).toIso8601String().split('T').first;

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
