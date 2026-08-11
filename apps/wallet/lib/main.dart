import 'dart:ui';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/app.dart';
import 'package:wallet/config/app_crash_listener.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';
import 'package:wallet/infrastructure/repository/settings_repository_impl.dart';
import 'package:wallet/route/app_router.dart';

/// Single entry point — no `main_dev.dart` / `main_prod.dart`.
///
/// Flavors, when they arrive, live entirely in the native projects, so adding
/// them will not touch this file.
Future<void> main() => AppCrashListener().runGuarded(() async {
  await EasyLocalization.ensureInitialized();

  // Loaded here rather than behind a bootstrap job: the chosen theme has to be
  // known before the first frame, and bootstrap runs *inside* the app — the
  // splash would flash in the wrong theme.
  final preferences = await SharedPreferences.getInstance();

  // All three are registered by hand, before runApp, because they sit
  // *upstream* of the container: configureDependencies() is itself one of the
  // bootstrap jobs, so none can be resolved from a container that does not
  // exist yet. Registering the port here also lets a widget test swap in a
  // fake one.
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
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
});
