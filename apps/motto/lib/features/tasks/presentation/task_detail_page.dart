import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One task, with the reason it is one.
///
/// A task with nowhere to read it is a checkbox, and a checkbox is not a
/// reason to open an app.
@RoutePage()
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({
    required this.task,
    required this.day,
    this.onDone,
    super.key,
  });

  final api.DailyTask task;
  final int day;
  final Future<void> Function()? onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('tasks.dayTitle'.tr(namedArgs: {'day': '$day'})),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: text.headlineSmall),
              const SizedBox(height: 16),
              Text(task.detail, style: text.bodyLarge),
              const Spacer(),
              if (task.done)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('tasks.done'.tr(), style: text.titleMedium),
                  ],
                )
              else if (onDone == null)
                // The chain has not started. Without this the button is still
                // here and still pops, so the tap looks like it counted.
                Text(
                  'tasks.lockedUntilChain'.tr(),
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                FilledButton(
                  onPressed: () async {
                    await onDone?.call();
                    // Navigator rather than the router: this is a leaf screen
                    // and popping is all it needs, which also lets it be
                    // tested without a router in the tree.
                    if (context.mounted) await Navigator.maybePop(context);
                  },
                  child: Text('tasks.didIt'.tr()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
