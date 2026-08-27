import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferences, because the whole thing is a start date, a set of days and one
/// make-up: nothing here is a credential and nothing here is big.
@lazySingleton
class ChainStore {
  ChainStore(this._preferences);

  static const _chainKey = 'chain';
  static const _hourKey = 'chain_reminder_hour';
  static const _unopenedKey = 'chain_unopened_in_a_row';

  /// What the picker opens on when the chain starts. Not a default that gets
  /// used silently — the hour is asked for.
  static const defaultHour = 9;

  final SharedPreferences _preferences;

  Chain read() {
    final stored = _preferences.getString(_chainKey);
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
      // A chain that cannot be parsed would fail to parse on every launch from
      // here on. Losing the streak is bad; losing the app is worse.
      return const Chain();
    }
  }

  Future<void> write(Chain chain) => _preferences.setString(
    _chainKey,
    jsonEncode({
      'startedOn': chain.startedOn?.toIso8601String(),
      'markedDays': [for (final day in chain.markedDays) day.toIso8601String()],
      'freezeUsedOn': chain.freezeUsedOn?.toIso8601String(),
    }),
  );

  int get hour => _preferences.getInt(_hourKey) ?? defaultHour;

  Future<void> setHour(int hour) => _preferences.setInt(_hourKey, hour);

  /// How many reminders in a row went unopened. The planner thins itself out
  /// once this passes its threshold.
  int get unopenedInARow => _preferences.getInt(_unopenedKey) ?? 0;

  Future<void> countUnopened() =>
      _preferences.setInt(_unopenedKey, unopenedInARow + 1);

  Future<void> resetUnopened() => _preferences.setInt(_unopenedKey, 0);

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
