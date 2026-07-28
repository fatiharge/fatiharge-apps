import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/theme/app_theme.dart';

/// Pumps a view with the localization and theme it gets in the app.
///
/// The views cannot be pumped bare: every amount and date goes through
/// `context.locale`, and `EasyLocalization.of(context)!` throws without an
/// ancestor. Loading the shipped `assets/translations` rather than faking them
/// also means a view naming a key that no longer exists fails here instead of
/// rendering the raw key on a phone.
///
/// The locale is pinned to `tr`: assertions on formatted money and translated
/// labels have to be reproducible, and CI's device locale is not.
/// Set [settle] to false for a view that never stops animating — a progress
/// indicator keeps scheduling frames, so `pumpAndSettle` would spin until it
/// times out rather than because anything is wrong.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget view, {
  bool settle = true,
}) async {
  // Stands in for the platform channel easy_localization saves the locale
  // through; without it initialisation throws.
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: _supported,
      path: 'assets/translations',
      fallbackLocale: _locale,
      startLocale: _locale,
      saveLocale: false,
      assetLoader: const _FileAssetLoader(),
      child: Builder(
        builder: (context) => MaterialApp(
          theme: AppTheme.light(),
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: Scaffold(body: view),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // One frame to resolve the translation future, one to draw with it.
    await tester.pump();
    await tester.pump();
  }
}

/// For a widget that builds its own MaterialApp, which `App` does.
Future<void> pumpApp(WidgetTester tester, Widget app) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: _supported,
      path: 'assets/translations',
      fallbackLocale: _locale,
      startLocale: _locale,
      saveLocale: false,
      assetLoader: const _FileAssetLoader(),
      child: app,
    ),
  );
  await tester.pump();
  await tester.pump();
}

const _locale = Locale('tr');
const _supported = [Locale('tr'), Locale('en')];

/// Reads the translation files straight off disk.
///
/// The shipped loader goes through `rootBundle`, whose real I/O does not
/// complete inside `pumpAndSettle`'s fake-async zone — the first pump in a file
/// would resolve and every one after it would hang with MaterialApp waiting on
/// a delegate, rendering an empty tree. Tests run on the VM, so reading the
/// same files synchronously is both simpler and still the real content.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      json.decode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}
