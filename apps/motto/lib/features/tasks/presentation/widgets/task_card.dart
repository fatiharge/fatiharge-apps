import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/support/presentation/widgets/trouble_sheet.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// One of the day's three things.
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.day,
    this.countable = true,
    super.key,
  });

  final api.DailyTask task;
  final int day;

  /// False before the chain starts. The task is still readable — it says what
  /// today asks for — but ticking it would record work against a chain that
  /// does not exist, and the day would come back empty.
  final bool countable;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<TaskCubit>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: task.done
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        leading: Checkbox(
          value: task.done,
          onChanged: countable ? (_) => _tick(context, cubit, task) : null,
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
            day: day,
            onDone: countable ? () => _tick(context, cubit, task) : null,
          ),
        ),
      ),
    );
  }
}

/// Ticks it, and says so when it did not stick.
///
/// The box unticks itself when the server never heard about it. Somebody who
/// ticked it, looked away and looked back reads that as the app losing their
/// work — so the box coming back needs a sentence next to it.
Future<void> _tick(
  BuildContext context,
  TaskCubit cubit,
  api.DailyTask task,
) async {
  if (await cubit.complete(task)) return;
  if (!context.mounted) return;

  await showTroubleSheet(
    context,
    failure: const _TickFailed(),
    retry: () => _tick(context, cubit, task),
  );
}

/// Stands in for the failure the cubit already reported: the screen needs to
/// know that something went wrong, not what.
class _TickFailed implements Exception {
  const _TickFailed();
}
