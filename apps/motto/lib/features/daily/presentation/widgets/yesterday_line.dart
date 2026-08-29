import 'package:flutter/material.dart';

/// What happened before today, in one line.
///
/// A screen that opens the same way on day one and day nine is a screen
/// nobody is inside of.
class YesterdayLine extends StatelessWidget {
  const YesterdayLine({required this.kept, super.key});

  final bool kept;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colour = kept ? scheme.primary : scheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          kept ? Icons.check_circle_outline : Icons.remove_circle_outline,
          size: 16,
          color: colour,
        ),
        const SizedBox(width: 6),
        Text(
          kept ? 'Dün işaretledin.' : 'Dün kaçtı.',
          style: text.bodyMedium?.copyWith(color: colour),
        ),
      ],
    );
  }
}
