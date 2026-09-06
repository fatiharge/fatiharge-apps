import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/level_bar.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/route/app_router.gr.dart';

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

class _SummaryPageState extends State<SummaryPage>
    with TickerProviderStateMixin {
  static const _fill = Duration(milliseconds: 1200);

  /// The result arrives in beats rather than all at once: the banner, then
  /// the card, then the takings counting up, then the stars, then the level.
  /// A screen that appears complete has nothing to say about how the run
  /// went — the order the numbers arrive in *is* the telling.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  /// Never stops: the button you are meant to press keeps asking.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  Animation<double> _beat(double from, double to) => CurvedAnimation(
    parent: _entrance,
    curve: Interval(from, to, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _entrance.dispose();
    _breath.dispose();
    super.dispose();
  }

  late final Progress _progress = getIt<Progress>();
  late final RunSummary? _run = _progress.sonOturum;

  late int _shownDay = _run?.gunOnce ?? _progress.gun;
  late double _from = Balance.ratio(_run?.xpOnce ?? 0, _shownDay);
  late double _to = (_run?.seviyeAtladi ?? false)
      ? 1
      : Balance.ratio(_progress.xp, _shownDay);

  /// Out of three: what the day asked for against what the run took. A day
  /// cleared in one run is three stars, which is what the target table was
  /// set to mean.
  int get _stars {
    final run = _run;
    if (run == null) return 0;
    final step = Balance.target(run.gunOnce) - Balance.floor(run.gunOnce);
    if (step <= 0) return 3;
    final share = run.kazanc / step;
    if (share >= 1) return 3;
    if (share >= 0.6) return 2;
    return share >= 0.25 ? 1 : 0;
  }

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
          if (_run?.seviyeAtladi ?? false) _Burst(animation: _entrance),
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
                      child: _Rise(
                        animation: _beat(0.08, 0.5),
                        child: _Card(
                          left: _Takings(
                            amount: _run?.kazanc ?? 0,
                            served: _run?.musteri ?? 0,
                            rozetler: _run?.rozetler ?? const [],
                            day: _run?.gunOnce ?? _progress.gun,
                            stars: _stars,
                            zirve: _run?.zirveTempo ?? TempoHali.normal,
                            reveal: _entrance,
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
                          right: _Choices(
                            amount: _run?.kazanc ?? 0,
                            reveal: _beat(0.55, 1),
                            breath: _breath,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _Drop(
                          animation: _beat(0, 0.35),
                          child: _Banner(text: 'ozet.baslik'.tr()),
                        ),
                      ),
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

/// Scales and lifts into place on its beat.
class _Rise extends StatelessWidget {
  const _Rise({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = animation.value.clamp(0.0, 1.2);
      return Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 26),
          child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
        ),
      );
    },
    child: child,
  );
}

/// Falls in from above the frame, with the overshoot the curve gives it.
class _Drop extends StatelessWidget {
  const _Drop({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Transform.translate(
      offset: Offset(0, (1 - animation.value.clamp(0.0, 1.0)) * -70),
      child: child,
    ),
    child: child,
  );
}

/// Rings going out behind the card when the run crossed a day.
///
/// The only thing on this screen that is pure celebration. It is drawn rather
/// than animated as widgets because it is two circles and a fade.
class _Burst extends StatelessWidget {
  const _Burst({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, _) =>
          CustomPaint(painter: _BurstPainter(animation.value)),
    ),
  );
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0.35) return;
    final centre = size.center(Offset.zero);
    for (var ring = 0; ring < 2; ring++) {
      final phase = ((t - 0.35) / 0.65 - ring * 0.22).clamp(0.0, 1.0);
      if (phase <= 0) continue;
      canvas.drawCircle(
        centre,
        size.shortestSide * (0.2 + phase * 0.85),
        Paint()
          ..color = KiymaPalette.ates.withValues(alpha: (1 - phase) * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * (1 - phase) + 1,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
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
    required this.rozetler,
    required this.day,
    required this.stars,
    required this.zirve,
    required this.reveal,
    required this.level,
  });

  final int amount;
  final int served;

  /// What the day earned. At most four are drawn — a wall of chips says
  /// nothing, and a day that earned five was a very good day either way.
  final List<Rozet> rozetler;

  static const _gosterilen = 4;

  final int day;
  final int stars;
  final TempoHali zirve;
  final Animation<double> reveal;
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
          // Held to one short line and scaled into it. The column is
          // `spaceBetween` inside a fixed box, so anything with a natural
          // height of its own pushes the takings off the bottom.
          if (rozetler.isNotEmpty)
            SizedBox(
              height: 22,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Row(
                  spacing: 6,
                  children: [
                    for (final rozet in rozetler.take(_gosterilen))
                      BrandChip(
                        label: 'rozet.${rozet.name}'.tr(),
                        icon: Icons.workspace_premium_rounded,
                      ),
                    if (rozetler.length > _gosterilen)
                      BrandChip(
                        label: '+${rozetler.length - _gosterilen}',
                      ),
                  ],
                ),
              ),
            ),
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
              _Stars(filled: stars, reveal: reveal),
              const SizedBox(width: 10),
              _TempoBadge(hal: zirve),
              const SizedBox(width: 10),
              // Expanded, not Flexible beside a Spacer: those split the room
              // between them and the sentence came out with an ellipsis.
              Expanded(
                child: Text(
                  'ozet.musteri'.tr(args: ['$served']),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontVariations: [FontVariation('wght', 700)],
                    fontSize: 11,
                    color: Color(0xFF8C7166),
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

/// Out of three. They pop in one after another rather than appearing, which
/// is the difference between a score and a result.
class _Stars extends StatelessWidget {
  const _Stars({required this.filled, required this.reveal});

  final int filled;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: reveal,
    builder: (context, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Transform.scale(
              scale: i < filled ? _pop(i) : 1,
              child: Icon(
                i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 22,
                color: i < filled ? KiymaPalette.kor : const Color(0x332E2A26),
              ),
            ),
          ),
      ],
    ),
  );

  /// Overshoots and settles, one star every 90 ms from the halfway beat.
  double _pop(int index) {
    final start = 0.45 + index * 0.06;
    final t = ((reveal.value - start) / 0.12).clamp(0.0, 1.0);
    if (t <= 0) return 0;
    return Curves.easeOutBack.transform(t);
  }
}

/// The best the counter read all run, in the band's own colour.
class _TempoBadge extends StatelessWidget {
  const _TempoBadge({required this.hal});

  final TempoHali hal;

  static const Map<TempoHali, Color> _colours = {
    TempoHali.soguk: Color(0xFF6C8AA6),
    TempoHali.normal: Color(0xFFCBA23C),
    TempoHali.isiniyor: Color(0xFFE8862A),
    TempoHali.ates: Color(0xFFE0452A),
  };

  @override
  Widget build(BuildContext context) {
    final colour = _colours[hal]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colour, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 12, color: colour),
          const SizedBox(width: 4),
          Text(
            'tempo.${hal.name}'.tr(),
            style: TextStyle(
              fontFamily: 'Rubik',
              fontVariations: const [FontVariation('wght', 900)],
              fontSize: 10,
              letterSpacing: 0.5,
              color: colour,
            ),
          ),
        ],
      ),
    );
  }
}

/// Never settles. The one thing on the screen that is asking to be pressed
/// has to look like it, and a button that blinks on and off reads as an
/// error — this one breathes.
class _Breathing extends StatelessWidget {
  const _Breathing({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Transform.scale(
      scale: 1 + 0.028 * Curves.easeInOut.transform(animation.value),
      child: child,
    ),
    child: child,
  );
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
  const _Choices({
    required this.amount,
    required this.reveal,
    required this.breath,
  });

  final int amount;
  final Animation<double> reveal;
  final Animation<double> breath;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _Rise(
        animation: reveal,
        child: _AdOffer(amount: amount, shine: breath),
      ),
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
            child: _Breathing(
              animation: breath,
              child: ChunkyButton(
                label: 'ozet.yeniden'.tr(),
                icon: Icons.play_arrow_rounded,
                big: true,
                color: KiymaPalette.krema,
                onPressed: () =>
                    unawaited(context.router.replaceAll([const DayRoute()])),
              ),
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
  const _AdOffer({required this.amount, required this.shine});

  final int amount;

  /// The same beat the primary button breathes on, spent differently: a band
  /// of light crossing the offer. The two buttons are asking for different
  /// things and should not ask in the same way.
  final Animation<double> shine;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: shine,
    builder: (context, child) => CustomPaint(
      foregroundPainter: _ShinePainter(shine.value),
      child: child,
    ),
    child: Container(
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
    ),
  );
}

/// A slanted band of light crossing the offer. It is the only optional thing
/// on the screen, so it is the only thing that advertises itself.
class _ShinePainter extends CustomPainter {
  const _ShinePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Only across the second half of the beat: a band that never leaves is
    // not a glint, it is a stripe.
    if (t < 0.5) return;
    final phase = (t - 0.5) * 2;
    final x = -60 + phase * (size.width + 120);
    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(14),
        ),
      )
      ..drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + 26, size.height)
          ..lineTo(x + 44, 0)
          ..lineTo(x + 18, 0)
          ..close(),
        Paint()..color = const Color(0x59FFFFFF),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ShinePainter old) => old.t != t;
}
