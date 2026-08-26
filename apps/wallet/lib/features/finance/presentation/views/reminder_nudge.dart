import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// A card rather than a dialog or a delayed popup: the offer is worth making
/// once the summary above it means something, but not worth interrupting for.
/// Whoever ignores it scrolls past; whoever is done with it closes it for good.
class ReminderNudge extends StatelessWidget {
  const ReminderNudge({
    required this.onAccept,
    required this.onDismiss,
    super.key,
  });

  /// After this many showings the offer stops on its own. Someone who has
  /// scrolled past it three times has answered.
  static const int maxShowings = 3;

  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr(LocaleKeys.dashboard_reminder_nudge),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    context.tr(LocaleKeys.dashboard_reminder_nudge_dismiss),
                  ),
                ),
                TextButton(
                  onPressed: onAccept,
                  child: Text(
                    context.tr(LocaleKeys.dashboard_reminder_nudge_accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
