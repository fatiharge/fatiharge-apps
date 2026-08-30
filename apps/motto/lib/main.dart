import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/app.dart';
import 'package:motto/config/app_crash_listener.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:motto/infrastructure/language/app_language.dart';
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
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale(AppLanguage.fallback),
      useOnlyLangCode: true,
      // The container is not up yet — configureDependencies is a bootstrap job
      // — so the stored choice is read straight from the preferences here. The
      // alternative is a frame in the wrong language before the right one.
      startLocale: await AppLanguage.stored(),
      child: MottoApp(router: getIt<AppRouter>()),
    ),
  );
}
