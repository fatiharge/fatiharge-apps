import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bans the string form of easy_localization's translate call from `lib/`.
///
/// Both forms read the same translation, but only the context one calls
/// `Localizations.of` — and that call is what subscribes the widget to the
/// locale. Without it the widget is never marked dirty when the language
/// changes, which is invisible to any test rendering under a single locale.
void main() {
  /// Captures the receiver, which is `null` for a string literal.
  final call = RegExp(r'''(?:(\w+)|['"])\s*\.\s*(tr|plural)\s*\(''');

  test('every translation in lib/ goes through the context', () {
    final offenders = <String>[];

    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('.g.dart'));

    for (final file in sources) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // Or the doc comments explaining this rule report themselves.
        if (lines[i].trimLeft().startsWith('//')) continue;

        for (final match in call.allMatches(lines[i])) {
          if (match.group(1) == 'context') continue;
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use context.tr(key) / context.plural(key, n) instead, so the widget '
          'rebuilds when the language changes:\n${offenders.join('\n')}',
    );
  });
}
