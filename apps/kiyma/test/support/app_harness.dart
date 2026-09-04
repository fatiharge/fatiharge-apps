import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/app.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the app the player gets, not a stand-in for it.
///
/// Tests used to build their own `MaterialApp.router` with no localisation
/// delegates, which meant `context.setLocale` could not change a single
/// rendered word and an untranslated string could ship with every test green.
/// [KiymaApp] is what `main` runs, so what is asserted here is what ships.
Future<void> pumpApp(WidgetTester tester, {required AppRouter router}) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: _supported,
      path: 'assets/translations',
      fallbackLocale: _locale,
      startLocale: _locale,
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const _FileAssetLoader(),
      child: KiymaApp(router: router),
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
