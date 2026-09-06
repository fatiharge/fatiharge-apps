import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// Functional, not finished: the design has an illustrated left two thirds
/// and a fuller button stack.
@RoutePage()
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) => Stack(
          children: [
            const Positioned.fill(child: _CounterBackdrop()),
            const Positioned(
              top: 14,
              left: 20,
              child: Wordmark(size: 34),
            ),
            Positioned(
              top: 14,
              right: 20,
              child: Row(
                children: [
                  BrandChip(
                    icon: Icons.paid_rounded,
                    label: 'hud.para'.tr(args: [goldText(state.para)]),
                  ),
                  const SizedBox(width: 8),
                  BrandChip(label: 'hud.gun'.tr(args: ['${state.gun}'])),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChunkyButton(
                        label: 'menu.oyna'.tr(),
                        icon: Icons.play_arrow_rounded,
                        big: true,
                        onPressed: () => context.router.push(const DayRoute()),
                      ),
                      const SizedBox(height: 14),
                      ChunkyButton(
                        label: 'menu.yukselt'.tr(),
                        icon: Icons.upgrade_rounded,
                        color: KiymaPalette.ahsap,
                        onPressed: () => context.router.push(const ShopRoute()),
                      ),
                      const SizedBox(height: 14),
                      ChunkyButton(
                        label: 'menu.dil'.tr(),
                        icon: Icons.translate_rounded,
                        color: KiymaPalette.celik,
                        onPressed: () => context.router.push(
                          LanguageRoute(firstRun: false),
                        ),
                        // Hidden behind three seconds, and only in a debug
                        // build: a way into the shop without grinding to it.
                        onHold: kDebugMode
                            ? () => context.read<KiymaCubit>().bagisla(1000)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The design asked for a placeholder illustration. The real scene is already
/// decoded by the time this screen exists, so it costs nothing to use it.
class _CounterBackdrop extends StatelessWidget {
  const _CounterBackdrop();

  @override
  Widget build(BuildContext context) {
    final scene = getIt<GameWorld>().art['back_scene.jpg'];
    if (scene == null) return const SizedBox();
    return ShaderMask(
      // Faded right so the buttons sit on cream, not on tiles.
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.white, Colors.transparent],
        stops: [0.55, 1],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Opacity(
        opacity: 0.5,
        child: RawImage(image: scene, fit: BoxFit.cover),
      ),
    );
  }
}
