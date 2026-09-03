import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/widgets.dart';

/// Loads the words before any test runs.
///
/// An unloaded `Localization` answers `.tr()` with the key itself, so without
/// this every widget test would be asserting on "gun_basi.basla" rather than
/// on what the screen says. Flutter runs this once for the whole tree.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  loadTranslations('tr');
  await testMain();
}

/// Read from disk rather than through the asset bundle: the bundle is not
/// built for a plain `flutter test`.
void loadTranslations(String language) {
  final decoded =
      jsonDecode(File('assets/translations/$language.json').readAsStringSync())
          as Map<String, dynamic>;
  Localization.load(Locale(language), translations: Translations(decoded));
}
