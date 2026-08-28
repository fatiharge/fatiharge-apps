import 'package:flutter/material.dart';

/// The wordmark, waiting.
///
/// The same thing the app opens on, so a wait reads as the app rather than as
/// a spinner that could belong to anything. Full-screen waits only: a bare
/// indicator is right for a strip inside a page, where a second wordmark would
/// just be the logo twice on one screen.
class MottoLoading extends StatelessWidget {
  const MottoLoading({this.label, super.key});

  /// What is being waited for, when it is worth saying.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Motto', style: text.displaySmall),
          const SizedBox(height: 28),
          // A short bar rather than a ring: it sits under the word like a rule
          // under a title, and the two read as one mark instead of a logo with
          // a spinner next to it.
          SizedBox(
            width: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          if (label case final String waiting) ...[
            const SizedBox(height: 20),
            Text(
              waiting,
              style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
