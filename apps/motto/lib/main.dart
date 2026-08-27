import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/app.dart';
import 'package:motto/config/app_crash_listener.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/startup/application/bootstrap_adapter.dart';
import 'package:motto/route/app_router.dart';

Future<void> main() => AppCrashListener().runGuarded(startApp);

/// Split from [main] because `runGuarded` takes over `FlutterError.onError` and
/// its own zone, both of which the test binding owns.
@visibleForTesting
Future<void> startApp() async {
  await EasyLocalization.ensureInitialized();

  // Upstream of the container: configureDependencies() is itself a bootstrap
  // job, so nothing registered here can come out of it.
  getIt
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerSingleton<BootstrapPort>(const BootstrapAdapter());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      useOnlyLangCode: true,
      child: MottoApp(router: getIt<AppRouter>()),
    ),
  );
}
