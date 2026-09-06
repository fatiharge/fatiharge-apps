import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/presentation/shop_ladder.dart';
import 'package:kiyma/presentation/shop_map.dart';

/// The things with nowhere to stand.
///
/// A sharper knife, an apprentice, a sign outside, tea for the queue — none
/// of them is an object in the kitchen, so none of them can be bought by
/// touching one. They get a list, reached from the shop rather than from the
/// menu: the room is the shop, and this is its back page.
@RoutePage()
class ShopListPage extends StatelessWidget {
  const ShopListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) {
          final cubit = context.read<KiymaCubit>();
          final unlocks = cubit.progress.unlocks;
          final gruplar = <Grup>[
            for (final grup in Grup.values)
              if (unlocks.grupAcik(grup) &&
                  Unlocks.kademeler(grup).every(
                    (unlock) => ShopMap.yeri(unlock.id) == null,
                  ))
                grup,
          ];

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
                        'magaza.gerisi_baslik'.tr(),
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
                      label: 'hud.para'.tr(args: [goldText(state.para)]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    for (final grup in gruplar)
                      Merdiven(
                        grup: grup,
                        unlocks: unlocks,
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
