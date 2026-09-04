import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/presentation/splash.dart';

/// The first route, and the only place the container is built: a route that
/// renders before it finds an empty one.
@RoutePage()
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  /// The whole of startup is about 60 ms, so this is almost entirely a brand
  /// hold, and it is paid on every launch. Long enough to read the wordmark
  /// and see half a breath of it; short enough not to be a toll. Under about
  /// a second it starts to read as a flicker instead, which is what the floor
  /// is for. Only the remainder is ever waited out.
  static const hold = Duration(milliseconds: 1800);

  @override
  Widget build(BuildContext context) => BootstrapPage.withProgress(
    port: getIt<BootstrapPort>(),
    minDuration: hold,
    runningBuilder: (context, state) =>
        SplashView(progress: state.progress, hold: hold),
    errorBuilder: (context, state, onRetry) =>
        _StartupError(state: state, onRetry: onRetry),
  );
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.state, this.onRetry});

  final BootstrapFailed state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_outlined,
              size: 48,
              color: KiymaPalette.kirmizi,
            ),
            const SizedBox(height: 16),
            Text(
              'baslangic.hata'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'baslangic.aciklama'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: KiymaPalette.soluk),
            ),
            // Nothing technical reaches a player (architecture/app-layers.md):
            // on the scene and art jobs there is no retry either, so a corrupt
            // install would leave somebody staring at an untranslated
            // FormatException under two lines that already said the useful
            // thing.
            if (kDebugMode) ...[
              const SizedBox(height: 10),
              Text(
                '${state.jobName}: ${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: KiymaPalette.soluk),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: Text('baslangic.yeniden'.tr()),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
