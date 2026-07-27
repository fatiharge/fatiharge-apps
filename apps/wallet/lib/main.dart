import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/app.dart';
import 'package:wallet/config/app_crash_listener.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';
import 'package:wallet/route/app_router.dart';

/// Single entry point — no `main_dev.dart` / `main_prod.dart`.
///
/// Flavors, when they arrive, live entirely in the native projects, so adding
/// them will not touch this file.
Future<void> main() => AppCrashListener().runGuarded(() async {
  await EasyLocalization.ensureInitialized();

  // Both are registered by hand, before runApp, because they sit *upstream* of
  // the container: configureDependencies() is itself one of the bootstrap
  // jobs, so neither can be resolved from a container that does not exist yet.
  // Registering the port here also lets a widget test swap in a fake one.
  getIt
    ..registerSingleton<RouteManager>(RouteManager())
    ..registerSingleton<BootstrapPort>(const BootstrapAdapter());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: const App(),
    ),
  );
});
