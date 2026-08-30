import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The two files, read as they ship.
///
/// A missing key does not crash easy_localization — it renders the key itself,
/// so "settings.language" appears on the screen where a word should be. That is
/// the kind of thing nobody notices until it is in the store, and it is exactly
/// what a test can see for free.
Map<String, String> flatten(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
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

  /// Turkish has one plural form and English has two, so `.one` exists on one
  /// side and not the other. What has to match is which sentences exist, not
  /// how many shapes each language needs for a count.
  Set<String> named(Map<String, String> flat) => {
    for (final key in flat.keys)
      key.replaceFirst(RegExp(r'\.(zero|one|two|few|many|other)$'), ''),
  };

  test('every Turkish key has an English one', () {
    expect(named(english).difference(named(turkish)), isEmpty);
    expect(named(turkish).difference(named(english)), isEmpty);
  });

  test('nothing is left blank', () {
    for (final entry in {...turkish, ...english}.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('a placeholder in one language is in the other', () {
    final braces = RegExp(r'\{[a-zA-Z]*\}');
    for (final key in turkish.keys) {
      // {day} in Turkish and nothing in English is a sentence that renders
      // with a number missing from the middle of it.
      expect(
        braces.allMatches(english[key]!).map((m) => m.group(0)).toSet(),
        braces.allMatches(turkish[key]!).map((m) => m.group(0)).toSet(),
        reason: key,
      );
    }
  });

  test('no English string is still Turkish', () {
    // The cheap version of a review: a letter that only exists in Turkish is
    // a line somebody forgot to translate.
    final onlyTurkish = RegExp('[çğıöşÇĞİÖŞ]');
    for (final entry in english.entries) {
      if (entry.key.startsWith('settings.languages')) continue;
      expect(onlyTurkish.hasMatch(entry.value), isFalse, reason: entry.key);
    }
  });

  test('every key the app asks for exists', () {
    final asked = RegExp(r"'([a-z][a-zA-Z0-9_]*(?:\.[a-zA-Z0-9_]+)+)'\s*\.(?:tr|plural)\(");
    final missing = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final match in asked.allMatches(file.readAsStringSync())) {
        final key = match.group(1)!;
        // Interpolated keys are built at runtime; this test cannot follow them.
        if (key.contains(r'$')) continue;
        if (!turkish.containsKey(key) &&
            !turkish.keys.any((each) => each.startsWith('$key.'))) {
          missing.add('${file.path}: $key');
        }
      }
    }

    expect(missing, isEmpty);
  });
}
