import 'dart:ui';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/app.dart';
import 'package:wallet/config/app_crash_listener.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';
import 'package:wallet/infrastructure/repository/settings_repository_impl.dart';
import 'package:wallet/route/app_router.dart';

Future<void> main() => AppCrashListener().runGuarded(startApp);

/// Split from [main] because `runGuarded` takes over `FlutterError.onError`
/// and its own zone, both of which the test binding owns.
@visibleForTesting
Future<void> startApp() async {
  await EasyLocalization.ensureInitialized();

  // Not a bootstrap job: bootstrap runs *inside* the app, so the splash would
  // flash in the wrong theme.
  final preferences = await SharedPreferences.getInstance();

  // Upstream of the container: configureDependencies() is itself a bootstrap
  // job, so none of these can come out of it.
  getIt
    ..registerSingleton<RouteManager>(RouteManager())
    ..registerSingleton<BootstrapPort>(const BootstrapAdapter())
    ..registerSingleton<SettingsRepository>(
      SettingsRepositoryImpl(
        preferences,
        region: PlatformDispatcher.instance.locale.countryCode,
      ),
    );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
