import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/palette.dart';

/// Design doc 10.4: between days only. Functional, not finished — the design
/// has category tabs and illustrated cards.
@RoutePage()
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) {
          final cubit = context.read<KiymaCubit>();
          final forSale = cubit.progress.unlocks.forSale.toList();
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
                child: forSale.isEmpty
                    ? Center(
                        child: Text(
                          'magaza.bos'.tr(),
                          style: const TextStyle(color: KiymaPalette.ahsap),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisExtent: 92,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: forSale.length,
                        itemBuilder: (context, index) => _UnlockCard(
                          unlock: forSale[index],
                          affordable: state.para >= forSale[index].price,
                          onBuy: () => cubit.buy(forSale[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _UnlockCard extends StatelessWidget {
  const _UnlockCard({
    required this.unlock,
    required this.affordable,
    required this.onBuy,
  });

  final Unlock unlock;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: KiymaPalette.krema,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: KiymaPalette.komur.withValues(alpha: 0.4),
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'kilit.${unlock.id}'.tr(),
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KiymaPalette.komur,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 34,
          child: ChunkyButton(
            label: '₺${unlock.price}',
            onPressed: affordable ? onBuy : null,
          ),
        ),
      ],
    ),
  );
}
