import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';


@RoutePage()
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  static const hold = Duration(seconds: 3);

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
            // The job name, always. Every job here is fatal, so whoever is
            // holding the phone is the one who has to report this, and "art"
            // versus "scene" is the whole of the report.
            const SizedBox(height: 10),
            Text(
              '${state.jobName}: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: KiymaPalette.soluk),
            ),
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
