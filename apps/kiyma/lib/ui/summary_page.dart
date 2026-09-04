import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/run_summary.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/level_bar.dart';
import 'package:kiyma/ui/palette.dart';

/// What a run was worth, over the counter it was earned on.
///
/// The takings and the level are the same number underneath and are shown as
/// two unrelated things, so progress reads as levelling and not as a balance.
@RoutePage()
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  static const _fill = Duration(milliseconds: 1200);

  late final Progress _progress = getIt<Progress>();
  late final RunSummary? _run = _progress.sonOturum;

  late int _shownDay = _run?.gunOnce ?? _progress.gun;
  late double _from = _ratio(_run?.xpOnce ?? 0, _shownDay);
  late double _to = (_run?.seviyeAtladi ?? false)
      ? 1
      : _ratio(_progress.xp, _shownDay);

  double _ratio(int xp, int day) {
    final floor = day <= 1 ? 0 : Balance.target(day - 1);
    final span = Balance.target(day) - floor;
    return span <= 0 ? 1 : ((xp - floor) / span).clamp(0, 1);
  }

  /// The bar tops out, the day turns over, and the rest fills the new level.
  void _levelUp() {
    if (!mounted || _shownDay >= _progress.gun) return;
    setState(() {
      _shownDay++;
      _from = 0;
      _to = _shownDay >= _progress.gun ? _ratio(_progress.xp, _shownDay) : 1;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KiymaPalette.zemin,
    body: Stack(
      fit: StackFit.expand,
      children: [
        const _Kitchen(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Banner(text: 'ozet.baslik'.tr()),
                Row(
                  children: [
                    Expanded(
                      child: _Takings(amount: _run?.kazanc ?? 0),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _Level(
                        day: _shownDay,
                        from: _from,
                        to: _to,
                        duration: _fill,
                        onEnd: _levelUp,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ChunkyButton(
                        label: 'ozet.menu'.tr(),
                        icon: Icons.home_rounded,
                        color: KiymaPalette.celik,
                        onPressed: () => unawaited(
                          context.router.replaceAll([const MenuRoute()]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ChunkyButton(
                        label: 'ozet.yeniden'.tr(),
                        icon: Icons.refresh_rounded,
                        big: true,
                        onPressed: () => unawaited(
                          context.router.replaceAll([const DayRoute()]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// The counter the run happened on, dimmed. The result belongs to the
/// kitchen, not to a card floating over nothing.
class _Kitchen extends StatelessWidget {
  const _Kitchen();

  @override
  Widget build(BuildContext context) {
    final scene = getIt<GameWorld>().art['back_scene.jpg'];
    return Stack(
      fit: StackFit.expand,
      children: [
        if (scene != null) RawImage(image: scene, fit: BoxFit.cover),
        const ColoredBox(color: Color(0xCC14100F)),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
    decoration: BoxDecoration(
      color: KiymaPalette.ahsap,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 4)),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Rubik',
        fontVariations: [FontVariation('wght', 800)],
        fontSize: 15,
        letterSpacing: 2,
        color: KiymaPalette.krema,
      ),
    ),
  );
}

class _Takings extends StatelessWidget {
  const _Takings({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(end: amount.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, shown, _) => Text(
          'ozet.kazanc'.tr(args: ['${shown.round()}']),
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 900)],
            fontSize: 54,
            height: 1,
            color: KiymaPalette.kor,
            shadows: [
              Shadow(color: KiymaPalette.komur, offset: Offset(0, 4)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      ChunkyButton(
        label: 'ozet.reklam'.tr(),
        icon: Icons.play_circle_outline_rounded,
        color: KiymaPalette.yesil,
        onPressed: () {},
      ),
    ],
  );
}

class _Level extends StatelessWidget {
  const _Level({
    required this.day,
    required this.from,
    required this.to,
    required this.duration,
    required this.onEnd,
  });

  final int day;
  final double from;
  final double to;
  final Duration duration;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 340),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _DayBadge(day: day, key: ValueKey(day)),
      ),
      const SizedBox(height: 14),
      LevelBar(value: to, from: from, duration: duration, onEnd: onEnd),
    ],
  );
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.day, super.key});

  final int day;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
    decoration: BoxDecoration(
      color: KiymaPalette.krema,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 4)),
      ],
    ),
    child: Text(
      'gun.baslik'.tr(args: ['$day']),
      style: const TextStyle(
        fontFamily: 'Rubik',
        fontVariations: [FontVariation('wght', 800)],
        fontSize: 22,
        color: KiymaPalette.komur,
      ),
    ),
  );
}
