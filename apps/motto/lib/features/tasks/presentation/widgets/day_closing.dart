import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
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
            child: const Text('Zincirini başlat'),
          ),
          const SizedBox(height: 8),
          // Said before the tap rather than after: a button that opens a
          // clock nobody expected is a button people cancel.
          Text(
            'Hatırlatma saatini soracağım.',
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
        child: const Text('Dönemi kapat'),
      );
    }

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.canFreeze(now)) ...[
          Text('Bir gün kaçtı. Telafi hakkın duruyor.', style: text.bodyMedium),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.read<ChainCubit>().useFreeze(),
            child: const Text('Telafi et'),
          ),
          TextButton(
            onPressed: () =>
                context.router.push(FaqRoute(openItem: 'chain_broken')),
            child: const Text('Telafi nasıl çalışıyor?'),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          onPressed: state.markedToday(now) ? null : () => _mark(context),
          child: Text(
            state.markedToday(now) ? 'Bugün işaretlendi' : 'Bugünü işaretle',
          ),
        ),
        if (!state.remindersAllowed) ...[
          const SizedBox(height: 12),
          Text(
            'Hatırlatıcılar kapalı. Zincir yine de işliyor.',
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
      helpText: 'Hatırlatma saati',
    );
    if (picked == null) return;

    await cubit.start(hour: picked.hour);
  }

  Future<void> _mark(BuildContext context) async {
    final mascot = MascotHost.of(context);
    final tasks = context.read<TaskCubit>();
    await context.read<ChainCubit>().markToday();
    mascot?.celebrate();
    // The day moves with the chain, so marking it is what makes tomorrow's
    // tasks tomorrow's.
    await tasks.load();
  }
}
