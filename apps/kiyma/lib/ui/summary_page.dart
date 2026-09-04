import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/level_bar.dart';
import 'package:kiyma/ui/palette.dart';

/// What a run was worth.
///
/// The takings and the level are the same number underneath; they are shown
/// as two unrelated things on purpose, so progress reads as levelling rather
/// than as a bank balance.
@RoutePage()
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  static const _fill = Duration(milliseconds: 1100);

  late final KiymaCubit _cubit = getIt<KiymaCubit>();
  late final RunSummary? _run = _cubit.state.oturum;

  late int _shownDay = _run?.gunOnce ?? _cubit.state.gun;
  late double _from = _ratio(_run?.xpOnce ?? 0, _shownDay);
  late double _to = (_run?.seviyeAtladi ?? false)
      ? 1
      : _ratio(_cubit.state.xp, _shownDay);

  /// Where [xp] sits between the bounds of [day]'s level.
  double _ratio(int xp, int day) {
    final floor = day <= 1 ? 0 : Balance.target(day - 1);
    final span = Balance.target(day) - floor;
    return span <= 0 ? 1 : ((xp - floor) / span).clamp(0, 1);
  }

  /// The bar tops out, the day turns over, and the rest of the XP fills the
  /// new level.
  void _levelUp() {
    if (!mounted || _shownDay >= _cubit.state.gun) return;
    setState(() {
      _shownDay++;
      _from = 0;
      _to = _shownDay >= _cubit.state.gun
          ? _ratio(_cubit.state.xp, _shownDay)
          : 1;
    });
  }

  @override
  Widget build(BuildContext context) => BrandBackground(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: BrandCard(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ozet.baslik'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: KiymaPalette.komur,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ozet.kazanc'.tr(args: ['${_run?.kazanc ?? 0}']),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: KiymaPalette.ates,
                ),
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                label: 'ozet.reklam'.tr(),
                icon: Icons.play_circle_outline_rounded,
                color: KiymaPalette.yesil,
                onPressed: () {},
              ),
              const SizedBox(height: 22),
              _Level(day: _shownDay),
              const SizedBox(height: 8),
              LevelBar(
                value: _to,
                from: _from,
                duration: _fill,
                onEnd: _levelUp,
              ),
              const SizedBox(height: 22),
              ChunkyButton(
                label: 'ozet.yeniden'.tr(),
                icon: Icons.refresh_rounded,
                big: true,
                onPressed: () =>
                    unawaited(context.router.replaceAll([const DayRoute()])),
              ),
              const SizedBox(height: 12),
              ChunkyButton(
                label: 'ozet.menu'.tr(),
                icon: Icons.home_rounded,
                color: KiymaPalette.celik,
                onPressed: () =>
                    unawaited(context.router.replaceAll([const MenuRoute()])),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Level extends StatelessWidget {
  const _Level({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 320),
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: FadeTransition(opacity: animation, child: child),
    ),
    child: Text(
      'gun.baslik'.tr(args: ['$day']),
      key: ValueKey(day),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Rubik',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: KiymaPalette.ahsap,
      ),
    ),
  );
}
