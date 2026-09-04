import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/palette.dart';

/// The card between runs. Moving on is a button, not a gate: it opens once
/// the cumulative total clears the day's target.
@RoutePage()
class DayPage extends StatelessWidget {
  const DayPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) {
          final cubit = context.read<KiymaCubit>();
          return Stack(
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: BrandCard(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'gun.baslik'.tr(args: ['${state.gun}']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: KiymaPalette.komur,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Target(state: state),
                        const SizedBox(height: 18),
                        ChunkyButton(
                          label: 'gun.ac'.tr(),
                          icon: Icons.local_fire_department_rounded,
                          big: true,
                          onPressed: () =>
                              unawaited(context.router.push(const GameRoute())),
                        ),
                        const SizedBox(height: 12),
                        ChunkyButton(
                          label: 'gun.ilerlet'.tr(),
                          icon: Icons.east_rounded,
                          color: KiymaPalette.yesil,
                          onPressed: state.ilerleyebilir
                              ? cubit.advanceDay
                              : null,
                        ),
                        if (!state.ilerleyebilir) ...[
                          const SizedBox(height: 8),
                          Text(
                            'gun.kilitli'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: KiymaPalette.komur.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _Target extends StatelessWidget {
  const _Target({required this.state});

  final KiymaState state;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'gun.hedef'.tr(args: ['${state.toplamKazanc}', '${state.hedef}']),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: KiymaPalette.ahsap),
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: state.hedefOrani,
          minHeight: 8,
          backgroundColor: KiymaPalette.komur.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation(
            state.ilerleyebilir ? KiymaPalette.yesil : KiymaPalette.ates,
          ),
        ),
      ),
    ],
  );
}
