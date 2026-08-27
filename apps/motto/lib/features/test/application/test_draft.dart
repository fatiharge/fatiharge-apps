import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A test that was started and not finished.
///
/// Kept because the alternative is asking someone twenty questions twice. The
/// answers are worthless to anyone else, so preferences are enough — nothing
/// here is a credential.
@lazySingleton
class TestDraft {
  TestDraft(this._preferences);

  static const _key = 'test_draft';

  final SharedPreferences _preferences;

  Map<String, int> read() {
    final stored = _preferences.getString(_key);
    if (stored == null) return {};

    final decoded = jsonDecode(stored) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries) entry.key: entry.value as int,
    };
  }

  Future<void> write(Map<String, int> answers) =>
      _preferences.setString(_key, jsonEncode(answers));

  /// Cleared once the answers have been spent, so a finished test cannot be
  /// resumed into a second charge.
  Future<void> clear() => _preferences.remove(_key);
}
