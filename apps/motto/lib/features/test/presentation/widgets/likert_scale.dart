import 'package:flutter/material.dart';

/// Five targets rather than a slider: a slider asks for a gesture where a tap
/// will do, twenty times. Labels at the ends only; labelling all five turns
/// the screen into a form.
class LikertScale extends StatelessWidget {
  const LikertScale({required this.onSelected, this.selected, super.key});

  final int? selected;
  final ValueChanged<int> onSelected;

  static const points = 5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ends = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var point = 1; point <= points; point++)
              _Point(
                point: point,
                isSelected: selected == point,
                onTap: () => onSelected(point),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hiç katılmıyorum', style: ends),
            Text('Tamamen katılıyorum', style: ends),
          ],
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({
    required this.point,
    required this.isSelected,
    required this.onTap,
  });

  final int point;
  final bool isSelected;
  final VoidCallback onTap;

  /// The middle point is drawn smaller: the ends are the opinions, the middle
  /// is the absence of one, and equal circles invite it as if it were a third.
  double get _size => switch (point) {
    1 || 5 => 56,
    2 || 4 => 48,
    _ => 40,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$point / ${LikertScale.points}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Filled faintly rather than left empty: an outline alone on a
            // dark ground is a ring nobody can see, and this is the only
            // control on the screen.
            color: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outline,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
