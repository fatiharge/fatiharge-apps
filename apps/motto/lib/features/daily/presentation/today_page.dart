import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/presentation/widgets/archetype_row.dart';
import 'package:motto/features/daily/presentation/widgets/day_block.dart';
import 'package:motto/features/daily/presentation/widgets/period_done_banner.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';

/// What somebody has, and what today says about it.
///
/// Only those two. The chain and the three things live in Görevler, next to
/// each other, because marking the day and doing the day are the same act.
@RoutePage()
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugün')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
          children: [
            BlocBuilder<ChainCubit, ChainState>(
              builder: (context, chain) => chain.chain.periodDone
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: PeriodDoneBanner(),
                    )
                  : const SizedBox.shrink(),
            ),
            BlocBuilder<DailyCubit, DailyState>(
              builder: (context, daily) => DayBlock(state: daily),
            ),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profile) =>
                  BlocBuilder<DailyCubit, DailyState>(
                    builder: (context, daily) {
                      final row = ArchetypeRow.forState(profile, daily);
                      return row == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: row,
                            );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
