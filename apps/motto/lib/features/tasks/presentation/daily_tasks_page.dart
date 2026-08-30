import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/presentation/widgets/chain_strip.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/features/tasks/presentation/widgets/day_closing.dart';
import 'package:motto/features/tasks/presentation/widgets/task_card.dart';

/// Where the day gets done.
///
/// The run, the three things, and the button that closes the day — in that
/// order. The chain is what the three things are for, and a chain kept on
/// another tab is a number nobody connects to the work that moved it.
@RoutePage()
class DailyTasksPage extends StatelessWidget {
  const DailyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No back arrow: this is a tab, and there is nowhere behind it.
      appBar: AppBar(
        title: const Text('Görevler'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
            children: [
              // Drawn from the cache, so the run stays whatever the network
              // did. Losing the day count because the task list failed took a
              // working chain off the screen.
              const _Run(),
              BlocBuilder<ChainCubit, ChainState>(
                builder: (context, chain) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Middle(state: state, started: chain.chain.started),
                    DayClosing(state: chain),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Run extends StatelessWidget {
  const _Run();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChainCubit, ChainState>(
      builder: (context, chain) {
        final now = DateTime.now();
        return ChainStrip(
          chain: chain.chain,
          today: now,
          streak: chain.streakToday(now),
        );
      },
    );
  }
}

/// Whatever the task list has to say — the three things, or why they are not
/// there. It fails on its own and should look like it.
class _Middle extends StatelessWidget {
  const _Middle({required this.state, required this.started});

  final TaskState state;

  /// Whether there is a chain for the day's work to belong to.
  final bool started;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return switch (state.status) {
      TaskStatus.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      TaskStatus.failed => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünün görevleri alınamadı. Bağlantını kontrol edip tekrar '
              'dene.',
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
      _ when state.tasks.isEmpty => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text('Bugün için bir şey yok.', style: text.bodyLarge),
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            'BUGÜNÜN ÜÇ ŞEYİ · ${state.done}/${state.tasks.length}',
            style: text.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          if (!started) ...[
            const SizedBox(height: 8),
            Text(
              'Bunlar bugünün üç şeyi. Zincirini başlattığında '
              'işaretlenmeye açılıyorlar.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          for (final task in state.tasks)
            TaskCard(task: task, day: state.day, countable: started),
          const SizedBox(height: 20),
        ],
      ),
    };
  }
}
