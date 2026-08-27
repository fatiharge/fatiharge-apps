import 'package:flutter/material.dart';
import 'package:motto/features/chain/domain/chain.dart';

/// Below the day rather than in a tab of its own: a calendar someone has to
/// navigate to is a calendar nobody looks at, and what is worth seeing here is
/// the shape of the run, not the dates.
class ChainCalendar extends StatelessWidget {
  const ChainCalendar({required this.chain, required this.today, super.key});

  static const weeks = 4;

  final Chain chain;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final start = dayOf(today).subtract(const Duration(days: weeks * 7 - 1));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var offset = 0; offset < weeks * 7; offset++)
          _Dot(
            marked: chain.isMarked(start.add(Duration(days: offset))),
            isToday: offset == weeks * 7 - 1,
            scheme: scheme,
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.marked,
    required this.isToday,
    required this.scheme,
  });

  final bool marked;
  final bool isToday;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: marked ? scheme.primary : scheme.surfaceContainerHighest,
      border: isToday ? Border.all(color: scheme.onSurface, width: 1.5) : null,
    ),
  );
}
