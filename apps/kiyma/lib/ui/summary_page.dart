import 'dart:async';
import 'dart:math' as math;

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
/// Two columns: what the day made on the left, what to do next on the right.
/// The takings and the level are the same number underneath and are shown as
/// two unrelated things, so progress reads as levelling and not as a balance.
///
/// Laid out for a phone held sideways, which is the shape the whole game is:
/// a short, very wide box. The design this follows was drawn for a tablet, so
/// everything here is one row shorter and one size smaller than it was.
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
  late double _from = Balance.ratio(_run?.xpOnce ?? 0, _shownDay);
  late double _to = (_run?.seviyeAtladi ?? false)
      ? 1
      : Balance.ratio(_progress.xp, _shownDay);

  /// The bar tops out, the day turns over, and the rest fills the new level.
  void _levelUp() {
    if (!mounted || _shownDay >= _progress.gun) return;
    setState(() {
      _shownDay++;
      _from = 0;
      _to = _shownDay >= _progress.gun
          ? Balance.ratio(_progress.xp, _shownDay)
          : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final floor = Balance.floor(_shownDay);
    return Scaffold(
      backgroundColor: KiymaPalette.zemin,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Kitchen(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: _Fitted(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(child: _Skewers()),
                    Positioned.fill(
                      top: 17,
                      child: _Card(
                        left: _Takings(
                          amount: _run?.kazanc ?? 0,
                          served: _run?.musteri ?? 0,
                          day: _run?.gunOnce ?? _progress.gun,
                          level: _Level(
                            day: _shownDay,
                            xp: (_progress.xp - floor).clamp(
                              0,
                              Balance.target(_shownDay) - floor,
                            ),
                            target: Balance.target(_shownDay) - floor,
                            from: _from,
                            to: _to,
                            duration: _fill,
                            onEnd: _levelUp,
                          ),
                        ),
                        right: _Choices(amount: _run?.kazanc ?? 0),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(child: _Banner(text: 'ozet.baslik'.tr())),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The card is a fixed shape, not a stretched one.
///
/// A phone in landscape is wider and shorter than the tablet this was drawn
/// for, and left to fill the screen the two columns pull apart until the
/// numbers stop reading as one result. Capped and centred instead.
class _Fitted extends StatelessWidget {
  const _Fitted({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Center(
      child: SizedBox(
        width: math.min(box.maxWidth, 900),
        height: math.min(box.maxHeight, 306),
        child: child,
      ),
    ),
  );
}

/// A day that burned more than it sold really did lose gold, and the summary
/// says so. Printing "+0" instead would have been the other honest option;
/// this one keeps the level bar, which tweens backwards, telling the same
/// story as the number above it.
String _signed(int amount) => amount < 0 ? '$amount' : '+$amount';

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
        const ColoredBox(color: Color(0xE014100F)),
      ],
    );
  }
}

/// Two crossed skewers behind the banner. The only decoration on the screen,
/// and the reason the banner reads as a sign rather than as a title bar.
class _Skewers extends StatelessWidget {
  const _Skewers();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: SizedBox(
      height: 34,
      width: 420,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final angle in [0.10, -0.10])
            Transform.rotate(
              angle: angle,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: KiymaPalette.celik,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: KiymaPalette.komur, width: 2),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: KiymaPalette.krema,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 6)),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: left),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: right),
      ],
    ),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFF2E2A26),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0x99000000), offset: Offset(0, 4)),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 15,
          color: KiymaPalette.ates,
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 900)],
            fontSize: 15,
            letterSpacing: 2,
            color: KiymaPalette.krema,
          ),
        ),
        const SizedBox(width: 9),
        const Icon(
          Icons.local_fire_department_rounded,
          size: 15,
          color: KiymaPalette.ates,
        ),
      ],
    ),
  );
}

/// The left column: what the day made, and how far it moved the level.
class _Takings extends StatelessWidget {
  const _Takings({
    required this.amount,
    required this.served,
    required this.day,
    required this.level,
  });

  final int amount;
  final int served;
  final int day;
  final Widget level;

  @override
  Widget build(BuildContext context) {
    final coin = getIt<GameWorld>().art['altin'];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KiymaPalette.komur, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BrandChip(label: 'ozet.hasilat'.tr()),
              const Spacer(),
              Text(
                'ozet.gun_basarili'.tr(args: ['$day']),
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontVariations: [FontVariation('wght', 800)],
                  fontSize: 10,
                  letterSpacing: 0.6,
                  color: Color(0xFF8C7166),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (coin != null)
                SizedBox(
                  width: 46,
                  height: 34,
                  child: RawImage(image: coin, fit: BoxFit.contain),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: amount.toDouble()),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, shown, _) => Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'ozet.kazanc'.tr(args: [_signed(shown.round())]),
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontVariations: [FontVariation('wght', 900)],
                            fontSize: 40,
                            height: 1,
                            color: KiymaPalette.komur,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ozet.altin'.tr(),
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontVariations: [FontVariation('wght', 900)],
                            fontSize: 18,
                            height: 1,
                            letterSpacing: 1,
                            color: KiymaPalette.ates,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: KiymaPalette.yesil,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'ozet.musteri'.tr(args: ['$served']),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontVariations: [FontVariation('wght', 700)],
                    fontSize: 11,
                    color: KiymaPalette.komur,
                  ),
                ),
              ),
            ],
          ),
          level,
        ],
      ),
    );
  }
}

/// The level panel: which day, how far through it, and which one is next.
class _Level extends StatelessWidget {
  const _Level({
    required this.day,
    required this.xp,
    required this.target,
    required this.from,
    required this.to,
    required this.duration,
    required this.onEnd,
  });

  final int day;
  final int xp;
  final int target;
  final double from;
  final double to;
  final Duration duration;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
    decoration: BoxDecoration(
      color: const Color(0xFFF8ECDA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: KiymaPalette.komur, width: 2),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 14, color: KiymaPalette.ates),
            const SizedBox(width: 5),
            Text(
              'ozet.ilerleme'.tr(),
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontVariations: [FontVariation('wght', 800)],
                fontSize: 10,
                letterSpacing: 0.6,
                color: KiymaPalette.ates,
              ),
            ),
            const Spacer(),
            Text(
              'ozet.xp'.tr(args: ['$xp', '$target']),
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontVariations: [FontVariation('wght', 900)],
                fontSize: 10,
                color: KiymaPalette.komur,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            _DayBadge(day: day),
            const SizedBox(width: 8),
            Expanded(
              child: LevelBar(
                value: to,
                from: from,
                duration: duration,
                onEnd: onEnd,
              ),
            ),
            const SizedBox(width: 8),
            _DayBadge(day: day + 1, next: true),
          ],
        ),
      ],
    ),
  );
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.day, this.next = false});

  final int day;
  final bool next;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: next ? KiymaPalette.celik : KiymaPalette.krema,
      shape: BoxShape.circle,
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ozet.gun_rozet'.tr(),
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 700)],
            fontSize: 6,
            height: 1,
            letterSpacing: 0.4,
            color: KiymaPalette.komur,
          ),
        ),
        Text(
          '$day',
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 900)],
            fontSize: 13,
            height: 1.1,
            color: KiymaPalette.komur,
          ),
        ),
      ],
    ),
  );
}

/// The right column: the one tempting option, then the two real ones.
class _Choices extends StatelessWidget {
  const _Choices({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _AdOffer(amount: amount),
      Row(
        children: [
          Expanded(
            flex: 4,
            child: ChunkyButton(
              label: 'ozet.menu'.tr(),
              icon: Icons.home_rounded,
              color: KiymaPalette.celik,
              onPressed: () =>
                  unawaited(context.router.replaceAll([const MenuRoute()])),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: ChunkyButton(
              label: 'ozet.yeniden'.tr(),
              icon: Icons.play_arrow_rounded,
              big: true,
              color: KiymaPalette.krema,
              onPressed: () =>
                  unawaited(context.router.replaceAll([const DayRoute()])),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, size: 13, color: KiymaPalette.kor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'ozet.hazir'.tr(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontVariations: [FontVariation('wght', 700)],
                fontSize: 10,
                letterSpacing: 0.4,
                color: Color(0xFF8C7166),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Not wired to anything yet: there is no ad SDK in the build. It is here
/// because the shape of the screen depends on it being here.
class _AdOffer extends StatelessWidget {
  const _AdOffer({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: KiymaPalette.ates,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: KiymaPalette.komur, width: 2),
      boxShadow: const [
        BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 4)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: KiymaPalette.komur,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 20,
            color: KiymaPalette.kor,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ozet.reklam'.tr(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontVariations: [FontVariation('wght', 900)],
                  fontSize: 12,
                  height: 1.2,
                  letterSpacing: 0.6,
                  color: KiymaPalette.krema,
                ),
              ),
              Text(
                'ozet.reklam_alt'.tr(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontVariations: [FontVariation('wght', 600)],
                  fontSize: 9,
                  height: 1.3,
                  color: Color(0xCCFFFFFF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: KiymaPalette.yesil,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: KiymaPalette.komur, width: 2),
          ),
          child: Text(
            'ozet.kazanc'.tr(args: [_signed(amount * 2)]),
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontVariations: [FontVariation('wght', 900)],
              fontSize: 12,
              height: 1,
              color: KiymaPalette.komur,
            ),
          ),
        ),
      ],
    ),
  );
}
