import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/days/application/days_cubit.dart';
import 'package:motto/features/days/presentation/widgets/day_sheet.dart';
import 'package:motto/features/days/presentation/widgets/period_grid.dart';
import 'package:motto/features/support/presentation/widgets/could_not_load.dart';
import 'package:motto/features/support/presentation/widgets/settings_button.dart';

/// Every day that was marked, and the words each one carried.
///
/// The chain used to be a forty-pixel strip on one tab — the thing the whole
/// product is about, shown as an ornament. Here it is the screen, and it is
/// also the index: a day is a door to what that day said.
@RoutePage()
class DaysPage extends StatelessWidget {
  const DaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('days.title'.tr()),
        automaticallyImplyLeading: false,
        actions: const [SettingsButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<DaysCubit, DaysState>(
          builder: (context, state) => switch (state.status) {
            DaysStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            DaysStatus.failed => CouldNotLoad(
              said: 'days.failed'.tr(),
              retry: context.read<DaysCubit>().load,
            ),
            DaysStatus.ready when state.empty => const _Nothing(),
            DaysStatus.ready => _Runs(state: state),
          },
        ),
      ),
    );
  }
}

class _Runs extends StatelessWidget {
  const _Runs({required this.state});

  final DaysState state;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
      itemCount: state.periods.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Divider(height: 1),
      ),
      itemBuilder: (context, index) {
        final period = state.periods[index];
        return PeriodGrid(
          period: period,
          onDay: (place) {
            final pack = state.pack;
            final archetype = state.archetypeId;
            // Without a package or an archetype there is a grid and nothing
            // behind it, and a box that opens onto nothing is worse than one
            // that does not open.
            if (pack == null || archetype == null) return;
            unawaited(
              showDaySheet(
                context,
                pack: pack,
                archetypeId: archetype,
                place: place,
              ),
            );
          },
        );
      },
    );
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'days.empty'.tr(),
          textAlign: TextAlign.center,
          style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
