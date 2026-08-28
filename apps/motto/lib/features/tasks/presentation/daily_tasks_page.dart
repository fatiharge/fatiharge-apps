import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/presentation/widgets/chain_strip.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// Where the day gets done.
///
/// The run, the three things, and the button that closes the day — in that
/// order, on one screen. They belong together: the chain is what the three
/// things are for, and a chain kept on another tab is a number nobody connects
/// to the work that moved it.
@RoutePage()
class DailyTasksPage extends StatelessWidget {
  const DailyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TaskCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
      ],
      child: const _DailyTasksView(),
    );
  }
}

class _DailyTasksView extends StatelessWidget {
  const _DailyTasksView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // No back arrow: this is a tab, and there is nowhere behind it.
      appBar: AppBar(
        title: const Text('Görevler'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            // The run is drawn from the cache, so it stays whatever the
            // network did. Losing the day count and the mark button because
            // the task list failed took a working chain off the screen.
            final chain = BlocBuilder<ChainCubit, ChainState>(
              builder: (context, chainState) {
                final now = DateTime.now();
                return ChainStrip(
                  chain: chainState.chain,
                  today: now,
                  streak: chainState.streakToday(now),
                );
              },
            );

            if (state.status == TaskStatus.loading) {
              return _framed(
                context,
                chain,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (state.status == TaskStatus.failed) {
              return _framed(
                context,
                chain,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bugünün görevleri alınamadı. Bağlantını kontrol edip '
                        'tekrar dene.',
                        style: text.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: context.read<TaskCubit>().unawaitedLoad,
                        child: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state.tasks.isEmpty) {
              return _framed(
                context,
                chain,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text('Bugün için bir şey yok.', style: text.bodyLarge),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
              children: [
                chain,
                const SizedBox(height: 28),
                Text(
                  'BUGÜNÜN ÜÇ ŞEYİ · ${state.done}/${state.tasks.length}',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                for (final task in state.tasks)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: task.done
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                      leading: Checkbox(
                        value: task.done,
                        onChanged: (_) =>
                            context.read<TaskCubit>().complete(task),
                      ),
                      title: Text(task.title, style: text.titleSmall),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ),
                      onTap: () => context.router.push(
                        TaskDetailRoute(
                          task: task,
                          day: state.day,
                          onDone: () =>
                              context.read<TaskCubit>().complete(task),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                BlocBuilder<ChainCubit, ChainState>(
                  builder: (context, chainState) =>
                      _closing(context, chainState, text, scheme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The run, then whatever the task list has to say, then the day's button.
  /// Three things that fail independently and should look like it.
  Widget _framed(BuildContext context, Widget chain, Widget middle) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      children: [
        chain,
        middle,
        BlocBuilder<ChainCubit, ChainState>(
          builder: (context, chainState) => _closing(
            context,
            chainState,
            Theme.of(context).textTheme,
            Theme.of(context).colorScheme,
          ),
        ),
      ],
    );
  }

  /// What closes the day. Under the three things rather than over them: the
  /// button means something once the work above it is done.
  Widget _closing(
    BuildContext context,
    ChainState state,
    TextTheme text,
    ColorScheme scheme,
  ) {
    final now = DateTime.now();

    if (!state.chain.started) {
      return FilledButton(
        onPressed: () => _askHourThenStart(context),
        child: const Text('Zincirini başlat'),
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

  Future<void> _askHourThenStart(BuildContext context) async {
    final cubit = context.read<ChainCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: ChainStore.defaultHour, minute: 0),
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
