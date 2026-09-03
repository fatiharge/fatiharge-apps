import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/unlocks.dart';

/// The two files, read as they ship.
///
/// A missing key does not crash easy_localization — it renders the key, so
/// "magaza.bakiye" appears where a sentence should be. Nobody notices that
/// until it is in the store, and a test sees it for free.
Map<String, String> flatten(String path) {
  final decoded =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final flat = <String, String>{};

  void walk(String prefix, Map<String, dynamic> node) {
    for (final entry in node.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        walk(key, value);
      } else {
        flat[key] = value as String;
      }
    }
  }

  walk('', decoded);
  return flat;
}

void main() {
  late Map<String, String> turkish;
  late Map<String, String> english;

  setUpAll(() {
    turkish = flatten('assets/translations/tr.json');
    english = flatten('assets/translations/en.json');
  });

  test('the two languages carry the same keys', () {
    expect(turkish.keys.toSet(), english.keys.toSet());
  });

  test('a key takes the same number of placeholders in both', () {
    for (final key in turkish.keys) {
      expect(
        '{}'.allMatches(english[key]!).length,
        '{}'.allMatches(turkish[key]!).length,
        reason: key,
      );
    }
  });

  test('every lock in the catalogue has a name', () {
    for (final unlock in Unlocks.catalogue) {
      expect(turkish, contains('kilit.${unlock.id}'), reason: unlock.id);
    }
  });

  test('nothing is left empty', () {
    for (final entry in {...turkish, ...english}.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });
}
