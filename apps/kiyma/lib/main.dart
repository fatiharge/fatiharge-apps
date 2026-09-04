import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiyma/app.dart';
import 'package:kiyma/config/app_crash_listener.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:kiyma/route/app_navigator.dart';

Future<void> main() => AppCrashListener().runGuarded(startApp);

/// Split from [main] because `runGuarded` takes over `FlutterError.onError`
/// and its own zone, both of which the test binding owns.
@visibleForTesting
Future<void> startApp() async {
  await EasyLocalization.ensureInitialized();

  // Landscape only, and no system bars. The counter is measured in one fixed
  // 1024x576 space; a rotation would letterbox it down to a strip, and a
  // system gesture bar sits exactly where the waiting shelves are.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Upstream of the container: configureDependencies is itself a bootstrap
  // job, so nothing registered here can come out of it.
  getIt
    ..registerSingleton<AppNavigator>(AppNavigator())
    ..registerSingleton<BootstrapPort>(const BootstrapAdapter());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      useOnlyLangCode: true,
      child: KiymaApp(
        port: getIt<BootstrapPort>(),
        navigator: getIt<AppNavigator>(),
      ),
    ),
  );
}
