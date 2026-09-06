import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/palette.dart';

/// Design doc 10.4: between days only. Functional, not finished — the design
/// has category tabs and illustrated cards.
@RoutePage()
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) {
          final cubit = context.read<KiymaCubit>();
          final unlocks = cubit.progress.unlocks;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: KiymaPalette.komur,
                      onPressed: () => context.router.maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'magaza.baslik'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KiymaPalette.komur,
                        ),
                      ),
                    ),
                    BrandChip(
                      icon: Icons.payments_outlined,
                      label: 'hud.para'.tr(args: ['${state.para}']),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    for (final grup in Grup.values)
                      if (unlocks.grupAcik(grup))
                        _Merdiven(
                          grup: grup,
                          kademe: unlocks.kademe(grup),
                          para: state.para,
                          onBuy: cubit.buy,
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// One ladder: the heading, and every rung whether or not it is reachable.
///
/// The shop used to list only what could be bought right now, which meant a
/// player on day three saw four rows and no reason to believe there was a
/// game past them. A ladder that shows its top is what makes the bottom
/// worth climbing — even, and especially, for somebody who will stop before
/// they reach it.
class _Merdiven extends StatelessWidget {
  const _Merdiven({
    required this.grup,
    required this.kademe,
    required this.para,
    required this.onBuy,
  });

  final Grup grup;
  final int kademe;
  final int para;
  final void Function(Unlock) onBuy;

  @override
  Widget build(BuildContext context) {
    final rungs = Unlocks.kademeler(grup);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'grup.${grup.id}'.tr(),
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: KiymaPalette.komur,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$kademe/${rungs.length}',
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: KiymaPalette.celik,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final unlock in rungs)
                SizedBox(
                  width: 210,
                  height: 78,
                  child: _UnlockCard(
                    unlock: unlock,
                    alindi: unlock.kademe <= kademe,
                    sirada: unlock.kademe == kademe + 1,
                    affordable: para >= unlock.price,
                    onBuy: () => onBuy(unlock),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnlockCard extends StatelessWidget {
  const _UnlockCard({
    required this.unlock,
    required this.alindi,
    required this.sirada,
    required this.affordable,
    required this.onBuy,
  });

  final Unlock unlock;

  /// Already owned. Kept on screen rather than dropped: a ladder with its
  /// bottom rungs missing does not read as progress.
  final bool alindi;

  /// The next rung. The only one money can reach.
  final bool sirada;

  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: alindi || sirada ? 1 : 0.45,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: alindi
            ? KiymaPalette.krema.withValues(alpha: 0.55)
            : KiymaPalette.krema,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: KiymaPalette.komur.withValues(alpha: sirada ? 0.7 : 0.25),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'kilit.${unlock.id}'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KiymaPalette.komur,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 30,
            child: alindi
                ? const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: KiymaPalette.celik,
                    ),
                  )
                : ChunkyButton(
                    // No currency symbol anywhere: the game pays in gold, and
                    // Rubik has no lira glyph, so it came out as a box.
                    label: '${unlock.price}',
                    icon: Icons.paid_rounded,
                    onPressed: sirada && affordable ? onBuy : null,
                  ),
          ),
        ],
      ),
    ),
  );
}
