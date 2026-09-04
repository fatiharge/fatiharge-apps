import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/app.dart';
import 'package:kiyma/config/app_crash_listener.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:kiyma/route/app_router.dart';

Future<void> main() => AppCrashListener().runGuarded(startApp);

/// Split from [main] because `runGuarded` takes over `FlutterError.onError`
/// and its own zone, both of which the test binding owns.
///
/// Everything that can be a startup job is one — the orientation lock
/// included. What is left is the two things the frameworks insist happen
/// first: easy_localization has to load its saved locale before the widget
/// above the app is built, and the router has to exist before
/// `MaterialApp.router` asks it for a config.
@visibleForTesting
Future<void> startApp() async {
  await EasyLocalization.ensureInitialized();

  // Upstream of the container: configureDependencies is itself a bootstrap
  // job, so nothing registered here can come out of it.
  getIt
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerSingleton<BootstrapPort>(const BootstrapAdapter());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      useOnlyLangCode: true,
      child: KiymaApp(router: getIt<AppRouter>()),
    ),
  );
}
