import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// The day's three things, on their own.
///
/// A tab rather than a strip under the day: three checkboxes squeezed between
/// two blocks of text is a list nobody reads, and the detail behind each one is
/// the reason they are worth doing rather than ticking. It is also the thing
/// the app is opened to do, and that belongs in the bar.
@RoutePage()
class DailyTasksPage extends StatelessWidget {
  const DailyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskCubit>()..unawaitedLoad(),
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
        title: const Text('Bugünün üç şeyi'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state.status == TaskStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TaskStatus.failed) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Bugünün görevleri alınamadı. Bağlantını kontrol edip '
                    'tekrar dene.',
                  ),
                ),
              );
            }
            if (state.tasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Bugün için bir şey yok.'),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
              children: [
                Text(
                  '${state.day}. GÜN · ${state.done}/${state.tasks.length}',
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
              ],
            );
          },
        ),
      ),
    );
  }
}
