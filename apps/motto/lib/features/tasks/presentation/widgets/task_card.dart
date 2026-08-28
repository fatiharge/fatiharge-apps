import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// One of the day's three things.
class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, required this.day, super.key});

  final api.DailyTask task;
  final int day;

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
          onChanged: (_) => cubit.complete(task),
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
            onDone: () => cubit.complete(task),
          ),
        ),
      ),
    );
  }
}
