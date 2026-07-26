import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two failure modes of key-based localization, both of which are
/// silent at runtime: easy_localization just renders the raw key.
///
/// The generator has a sharp edge that motivated the second test — it treats
/// *any* leaf named `one`, `other`, `few`, ... as a plural form and emits no
/// constant for it. `category.other` therefore had to be renamed to
/// `category.misc`. Without this test that discovery would have been a
/// runtime surprise instead of a red build.
void main() {
  const pluralForms = {'zero', 'one', 'two', 'few', 'many', 'other'};

  Map<String, dynamic> load(String locale) =>
      json.decode(File('assets/translations/$locale.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Flattens to dotted paths: `{'a': {'b': 1}}` -> `{'a.b'}`.
  Set<String> leafPaths(Map<String, dynamic> node, [String prefix = '']) {
    final paths = <String>{};
    node.forEach((key, value) {
      final path = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        paths.addAll(leafPaths(value, path));
      } else {
        paths.add(path);
      }
    });
    return paths;
  }

  /// The paths that need a `LocaleKeys` constant.
  ///
  /// A node whose children are *all* plural forms is addressed by its own
  /// path (`budget.exceeded_warning`), so the children are not required.
  Set<String> expectedConstants(
    Map<String, dynamic> node, [
    String prefix = '',
  ]) {
    final expected = <String>{};
    node.forEach((key, value) {
      final path = prefix.isEmpty ? key : '$prefix.$key';
      if (value is! Map<String, dynamic>) {
        expected.add(path);
        return;
      }
      final isPluralGroup =
          value.keys.isNotEmpty && value.keys.every(pluralForms.contains);
      if (isPluralGroup) {
        expected.add(path);
      } else {
        expected.addAll(expectedConstants(value, path));
      }
    });
    return expected;
  }

  test('tr and en define exactly the same keys', () {
    final tr = leafPaths(load('tr'));
    final en = leafPaths(load('en'));

    expect(
      tr.difference(en),
      isEmpty,
      reason: 'keys present in tr.json but missing from en.json',
    );
    expect(
      en.difference(tr),
      isEmpty,
      reason: 'keys present in en.json but missing from tr.json',
    );
  });

  test('every translation key has a generated LocaleKeys constant', () {
    final generated = File(
      'lib/generated/locale_keys.g.dart',
    ).readAsStringSync();

    final missing = expectedConstants(
      load('tr'),
    ).where((path) => !generated.contains("= '$path';")).toList()..sort();

    expect(
      missing,
      isEmpty,
      reason:
          'No constant was generated for these keys. Run '
          '`melos run generate:l10n`. If a key is still missing afterwards, '
          'check whether its last segment is a plural form name '
          '(${pluralForms.join(', ')}) — the generator drops those, so the '
          'key has to be renamed.',
    );
  });
}
