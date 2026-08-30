import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/widgets.dart';

/// Loads the words before any test runs.
///
/// Every screen reads its sentences through `.tr()` now, and an unloaded
/// `Localization` answers with the key itself — so without this every widget
/// test would be asserting on "tasks.done" instead of on what the screen says.
///
/// Here rather than in fifty `setUp`s: Flutter runs this file once for the
/// whole tree, and a test that forgets the setup fails in a way that looks like
/// a broken screen.
///
/// Turkish, because that is what the tests are written in. A test that wants
/// the other language loads it itself.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // No binding here: the test binding is the one that has to be first, and
  // loading the words needs nothing from it.
  loadTranslations('tr');
  await testMain();
}

/// The translation file as it ships, read from disk rather than through the
/// asset bundle: the bundle is not built in a plain `flutter test`.
void loadTranslations(String language) {
  final decoded =
      jsonDecode(File('assets/translations/$language.json').readAsStringSync())
          as Map<String, dynamic>;
  Localization.load(Locale(language), translations: Translations(decoded));
}
