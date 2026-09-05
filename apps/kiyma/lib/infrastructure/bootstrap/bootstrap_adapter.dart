import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/services.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/infrastructure/language_choice.dart';
import 'package:kiyma/infrastructure/progress_store.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:meta/meta.dart';

/// The orientation, then the container, then the scene, then the art.
///
/// The three that load are `restart`: there is no reduced game to fall back
/// to, and a scene that will not parse is not something a retry fixes.
class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    BootstrapJob('display', () async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Edge to edge, not immersive: the platform stopped honouring the Dart
      // opt-out at targetSdk 36, so the bars are hidden in MainActivity.kt
      // and this only says where the app is allowed to draw.
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0x00000000),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0x00000000),
        ),
      );
    }, errorPolicy: BootstrapErrorPolicy.skip),
    const BootstrapJob(
      'dependencies',
      configureDependencies,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
    BootstrapJob(
      'kayit',
      () async => getIt<ProgressStore>().restore(getIt<Progress>()),
      // A save that will not read is not a reason to refuse to play.
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
    BootstrapJob(
      'scene',
      () => getIt<GameWorld>().loadScene(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
    BootstrapJob(
      'art',
      () => getIt<GameWorld>().loadArt(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
  ];

  /// `replaceAll`, so a back gesture cannot land on a finished bootstrap.
  @override
  void bootstrapFinished() =>
      unawaited(getIt<AppRouter>().replaceAll([firstRoute()]));

  /// Split out so the order can be asserted: getting it wrong is invisible
  /// until somebody installs the app fresh.
  @visibleForTesting
  static PageRouteInfo<dynamic> firstRoute({bool? chosen}) =>
      (chosen ?? getIt<LanguageChoice>().made)
      ? const MenuRoute()
      : LanguageRoute();
}
