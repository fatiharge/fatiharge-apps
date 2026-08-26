import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/theme/app_theme.dart';

/// Loads the shipped translations, so a view naming a dead key fails here
/// rather than rendering the raw key on a phone. Locale pinned to `tr` because
/// CI's is not. Set [settle] false for a view that never stops animating.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget view, {
  bool settle = true,
}) async {
  // The platform channel easy_localization saves through; it throws without.
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

/// A lazy `ListView` leaves anything below 800x600 unbuilt, so `find.text`
/// misses it and the failure reads as missing content.
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

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

/// `rootBundle` I/O does not complete inside `pumpAndSettle`'s fake-async
/// zone, so every pump after the first hangs on an unresolved delegate.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      json.decode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}
