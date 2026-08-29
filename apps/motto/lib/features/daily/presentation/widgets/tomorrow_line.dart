import 'package:flutter/material.dart';

/// What is waiting, named.
///
/// "Yarın bir sürprizin var" is the sentence people learn to ignore.
class TomorrowLine extends StatelessWidget {
  const TomorrowLine({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: scheme.outlineVariant, height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'YARIN',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: text.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
