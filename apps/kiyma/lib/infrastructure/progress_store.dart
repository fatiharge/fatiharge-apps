import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the till, the day and the shop live between launches.
///
/// Nothing survived a cold start before this: money, the day number and every
/// unlock were fields on a singleton, so the whole between-days loop the shop
/// exists for only meant anything inside one process. The catalogue runs to
/// about nine thousand gold and day one takes twenty-four.
///
/// A store and nothing else, in the sense `architecture/app-layers.md` means:
/// it owns the key, the shape and the answer to "what if it is corrupt". It
/// decides nothing.
@lazySingleton
class ProgressStore {
  const ProgressStore(this._preferences);

  static const _key = 'progress';

  /// Bumped when the shape changes. A saved game from an older shape is
  /// dropped rather than guessed at — a wrong reading is worse than a fresh
  /// start, and this one is only ever a few runs old.
  static const _version = 1;

  final SharedPreferences _preferences;

  /// Pours what was saved into [progress]. Silent when there is nothing, or
  /// when what is there cannot be read.
  void restore(Progress progress) {
    final raw = _preferences.getString(_key);
    if (raw == null) return;
    try {
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      if (saved['v'] != _version) return;
      progress
        ..para = (saved['para'] as num).toInt()
        ..xp = (saved['xp'] as num).toInt()
        ..gun = (saved['gun'] as num).toInt();
      (saved['acik'] as List<dynamic>).cast<String>().forEach(
        progress.unlocks.open,
      );
    } on Object {
      // Unreadable now is unreadable on the next launch too.
      unawaited(_preferences.remove(_key));
    }
  }

  Future<void> save(Progress progress) => _preferences.setString(
    _key,
    jsonEncode({
      'v': _version,
      'para': progress.para,
      'xp': progress.xp,
      'gun': progress.gun,
      'acik': progress.unlocks.opened.toList(),
    }),
  );

  Future<void> clear() => _preferences.remove(_key);
}
