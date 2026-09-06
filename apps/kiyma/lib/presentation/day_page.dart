import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_rule.dart';
import 'package:kiyma/domain/trade_shape.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/level_bar.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The card a run starts from.
///
/// Its job is to say what is different about today. Five numbers move with
/// the day — the clock, how often people arrive, how long meat survives, how
/// long they wait, and what everything pays — and until this card listed them
/// the whole ramp was invisible: the game tightened five screws a day and
/// never said so.
@RoutePage()
class DayPage extends StatelessWidget {
  const DayPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) => Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: KiymaPalette.komur,
                  onPressed: () => context.router.maybePop(),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 16,
                ),
                child: BrandCard(
                  width: 720,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _Today(day: state.gun)),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _Start(state: state)),
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

/// The five dials, with how far each moved since yesterday.
class _Today extends StatelessWidget {
  const _Today({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.decimalPattern(context.locale.languageCode)
      ..maximumFractionDigits = 1;
    final was = day - 1;

    // The card is a promise, so it has to say what today will actually be
    // like: a race day is not the patience curve, it is the patience curve
    // times two thirds.
    final kural = DayRule.forDay(day);
    final onceki = DayRule.forDay(was);
    double sabir(int gun, DayRule kural) =>
        Balance.patience(gun) * kural.sabirCarpani;
    double pencere(int gun, DayRule kural) =>
        Balance.cookedWindow(gun) * kural.pencereCarpani;
    double carpan(int gun, DayRule kural) =>
        Balance.dayMultiplier(gun) * kural.odeme;

    String seconds(double value) => '${number.format(value)} sn';

    String clock(Duration length) {
      final rest = (length.inSeconds % 60).toString().padLeft(2, '0');
      return '${length.inMinutes}:$rest';
    }

    final rows = <_Dial>[
      _Dial(
        icon: Icons.schedule_rounded,
        label: 'gun.sure'.tr(),
        value: clock(Balance.runLength(day)),
        delta: day <= 1
            ? null
            : Balance.runLength(day).inSeconds -
                  Balance.runLength(was).inSeconds.toDouble(),
        unit: 'sn',
        moreIsBetter: true,
        number: number,
      ),
      _Dial(
        icon: Icons.groups_rounded,
        label: 'gun.gelis'.tr(),
        value: seconds(Balance.arrivalGap(day)),
        delta: day <= 1
            ? null
            : Balance.arrivalGap(day) - Balance.arrivalGap(was),
        unit: 'sn',
        moreIsBetter: true,
        number: number,
      ),
      _Dial(
        icon: Icons.local_fire_department_rounded,
        label: 'gun.yanma'.tr(),
        value: seconds(pencere(day, kural)),
        delta: day <= 1 ? null : pencere(day, kural) - pencere(was, onceki),
        unit: 'sn',
        moreIsBetter: true,
        number: number,
      ),
      _Dial(
        icon: Icons.hourglass_bottom_rounded,
        label: 'gun.sabir'.tr(),
        value: seconds(sabir(day, kural)),
        delta: day <= 1 ? null : sabir(day, kural) - sabir(was, onceki),
        unit: 'sn',
        moreIsBetter: true,
        number: number,
      ),
      _Dial(
        icon: Icons.payments_rounded,
        label: 'gun.carpan'.tr(),
        value: '×${number.format(carpan(day, kural))}',
        delta: day <= 1
            ? null
            : (carpan(day, kural) - carpan(was, onceki)) * 100,
        unit: '%',
        moreIsBetter: true,
        number: number,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            BrandChip(label: 'gun.bugun'.tr(), icon: Icons.today_rounded),
            // The shape of the day, named before it starts. A rush that can
            // be planned for is a shift; one that just happens is noise.
            BrandChip(
              label: 'gidis.${TradeShape.forDay(day).ad}'.tr(),
              icon: Icons.show_chart_rounded,
            ),
            // Only when there is one: three chips on a day with nothing
            // special about it would teach the player to stop reading them.
            if (!DayRule.forDay(day).adsiz)
              BrandChip(
                label: 'kural.${DayRule.forDay(day).id}'.tr(),
                icon: Icons.gavel_rounded,
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final row in rows) ...[
          row,
          const SizedBox(height: 6),
        ],
        if (!DayRule.forDay(day).adsiz) ...[
          const SizedBox(height: 2),
          _Satir(
            icon: Icons.gavel_rounded,
            text: 'kural.${DayRule.forDay(day).id}_ne'.tr(),
          ),
        ],
        const SizedBox(height: 2),
        _Satir(
          icon: Icons.flag_rounded,
          text: 'gun.hedef_ne'.tr(
            args: [
              '${(Balance.gunlukHedef(day) * kural.hedefCarpani).round()}',
              '${Balance.gunlukOdul(day)}',
            ],
          ),
        ),
      ],
    );
  }
}

/// One line of it: what the number is now, and which way it moved.
/// A line of plain sentence under the dials: what today's rule does, and
/// what the day is asking for. Not a dial — neither of them is a number
/// that moved since yesterday.
class _Satir extends StatelessWidget {
  const _Satir({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: KiymaPalette.celik),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: KiymaPalette.komur,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.unit,
    required this.moreIsBetter,
    required this.number,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Against yesterday, or null on the first day — there is no yesterday.
  final double? delta;
  final String unit;
  final bool moreIsBetter;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    // Day one has no yesterday, and every dial eventually hits its floor and
    // stops moving. Neither is worth a row of "±0".
    final fark = delta;
    final moved = fark != null && fark.abs() >= 0.05;
    final good = (fark ?? 0) > 0 == moreIsBetter;
    return Row(
      children: [
        Icon(icon, size: 15, color: KiymaPalette.ahsap),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontVariations: [FontVariation('wght', 600)],
              fontSize: 12,
              color: KiymaPalette.komur,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 900)],
            fontSize: 13,
            color: KiymaPalette.komur,
          ),
        ),
        SizedBox(
          width: 58,
          child: moved
              ? Text(
                  '${fark > 0 ? '+' : '−'}'
                  '${number.format(fark.abs())} $unit',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: 11,
                    color: good ? KiymaPalette.yesil : KiymaPalette.kirmizi,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// The right half: where the level is, what the money can reach, one thing
/// worth remembering, and the two ways out.
class _Start extends StatelessWidget {
  const _Start({required this.state});

  final KiymaState state;

  /// Cheapest thing the till can already cover. Naming it here is the only
  /// moment the player can act on it: the shop is one tap away and the run
  /// has not started.
  Unlock? get _affordable {
    Unlock? best;
    for (final unlock in getIt<KiymaCubit>().progress.unlocks.forSale) {
      if (unlock.price > state.para) continue;
      if (best == null || unlock.price < best.price) best = unlock;
    }
    return best;
  }

  /// Turns over with the day rather than at random, so it is stable within a
  /// day and different on the next one.
  static const _tips = 6;

  @override
  Widget build(BuildContext context) {
    final buy = _affordable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'gun.baslik'.tr(args: ['${state.gun}']),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: KiymaPalette.komur,
          ),
        ),
        const SizedBox(height: 10),
        // Past the last measured day the bar is still there and still moves,
        // but nothing new is behind it. The record is what a run is for from
        // here, so it takes the line the bar was explaining.
        if (context.read<KiymaCubit>().progress.ustaModu)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BrandChip(
              icon: Icons.emoji_events_rounded,
              label: 'gun.usta'.tr(
                args: [goldText(context.read<KiymaCubit>().progress.rekor)],
              ),
            ),
          ),
        LevelBar(value: state.seviyeOrani),
        const SizedBox(height: 14),
        _Tip(index: state.gun % _tips + 1),
        const SizedBox(height: 14),
        ChunkyButton(
          label: 'gun.ac'.tr(),
          icon: Icons.local_fire_department_rounded,
          big: true,
          onPressed: () => unawaited(context.router.push(const GameRoute())),
        ),
        const SizedBox(height: 10),
        ChunkyButton(
          label: buy == null
              ? 'menu.yukselt'.tr()
              : 'gun.alinabilir'.tr(
                  args: ['kilit.${buy.id}'.tr(), goldText(buy.price)],
                ),
          icon: buy == null
              ? Icons.upgrade_rounded
              : Icons.shopping_bag_rounded,
          color: buy == null ? KiymaPalette.ahsap : KiymaPalette.yesil,
          onPressed: () => unawaited(context.router.push(const ShopRoute())),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: KiymaPalette.ahsap.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          size: 15,
          color: KiymaPalette.ahsap,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'gun.ipucu_$index'.tr(),
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontVariations: [FontVariation('wght', 500)],
              fontSize: 11,
              height: 1.35,
              color: KiymaPalette.komur,
            ),
          ),
        ),
      ],
    ),
  );
}
