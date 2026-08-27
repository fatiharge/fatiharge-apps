import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/app.dart';
import 'package:motto/config/app_crash_listener.dart';
import 'package:motto/route/app_router.dart';

Future<void> main() => AppCrashListener().runGuarded(startApp);

/// Split from [main] because `runGuarded` takes over `FlutterError.onError` and
/// its own zone, both of which the test binding owns.
@visibleForTesting
Future<void> startApp() async {
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      useOnlyLangCode: true,
      child: MottoApp(router: AppRouter()),
    ),
  );
}
