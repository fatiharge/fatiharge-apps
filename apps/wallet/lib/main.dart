import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/app/app.dart';
import 'package:wallet/app/config/app_crash_listener.dart';
import 'package:wallet/app/config/injectable.dart';
import 'package:wallet/app/route/app_router.dart';

/// Single entry point — no `main_dev.dart` / `main_prod.dart`.
///
/// Flavors, when they arrive, live entirely in the native projects, so adding
/// them will not touch this file.
Future<void> main() => AppCrashListener().runGuarded(() async {
  await EasyLocalization.ensureInitialized();

  // Registered before runApp because the bootstrap adapter navigates through
  // it, and it runs outside the widget tree.
  getIt.registerSingleton<RouteManager>(RouteManager());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: const App(),
    ),
  );
});
