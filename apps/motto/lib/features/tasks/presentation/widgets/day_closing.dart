import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/features/support/presentation/widgets/trouble_sheet.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// What closes the day.
///
/// Under the three things rather than over them: the button means something
/// once the work above it is done.
class DayClosing extends StatelessWidget {
  const DayClosing({required this.state, super.key});

  final ChainState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    if (!state.chain.started) {
      final text = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => _askHourThenStart(context),
            child: Text('dayClosing.startChain'.tr()),
          ),
          const SizedBox(height: 8),
          // Said before the tap rather than after: a button that opens a
          // clock nobody expected is a button people cancel.
          Text(
            'dayClosing.willAskHour'.tr(),
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    // A finished run stops taking days. Marking a fifteenth would make the
    // strip read 15/14 and the period mean nothing.
    if (state.chain.periodDone) {
      return FilledButton(
        onPressed: () => context.router.push(const PeriodDoneRoute()),
        child: Text('dayClosing.closePeriod'.tr()),
      );
    }

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.canFreeze(now)) ...[
          Text('dayClosing.missedOne'.tr(), style: text.bodyMedium),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.read<ChainCubit>().useFreeze(),
            child: Text('dayClosing.makeUp'.tr()),
          ),
          TextButton(
            onPressed: () =>
                context.router.push(FaqRoute(openItem: 'chain_broken')),
            child: Text('dayClosing.howMakeUp'.tr()),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          onPressed: state.markedToday(now) ? null : () => _mark(context),
          child: Text(
            state.markedToday(now)
                ? 'dayClosing.markedToday'.tr()
                : 'dayClosing.markToday'.tr(),
          ),
        ),
        if (!state.remindersAllowed) ...[
          const SizedBox(height: 12),
          Text(
            'dayClosing.remindersOff'.tr(),
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  /// The hour is asked for rather than assumed: a reminder at the wrong time
  /// of day is the one that teaches people to swipe them away.
  Future<void> _askHourThenStart(BuildContext context) async {
    final cubit = context.read<ChainCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: ChainStore.defaultHour, minute: 0),
      helpText: 'dayClosing.reminderHour'.tr(),
    );
    if (picked == null) return;

    try {
      await cubit.start(hour: picked.hour);
    } on Object catch (failure) {
      // Starting is the one chain action with no offline path — there is no
      // chain yet to queue a day against. Failing silently left somebody
      // pressing the button and watching nothing happen.
      if (!context.mounted) return;
      await showTroubleSheet(
        context,
        failure: failure,
        retry: () => _askHourThenStart(context),
      );
    }
  }

  Future<void> _mark(BuildContext context) async {
    final mascot = MascotHost.of(context);
    final tasks = context.read<TaskCubit>();

    try {
      await context.read<ChainCubit>().markToday();
    } on Object catch (failure) {
      // A day marked offline is queued rather than lost, so this only fires
      // when something else went wrong — and then it has to be said.
      if (!context.mounted) return;
      await showTroubleSheet(
        context,
        failure: failure,
        retry: () => _mark(context),
      );
      return;
    }

    mascot?.celebrate();
    // The day moves with the chain, so marking it is what makes tomorrow's
    // tasks tomorrow's.
    await tasks.load();
  }
}
