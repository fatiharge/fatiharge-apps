import 'package:flutter/material.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/daily/domain/daily_assembler.dart';

/// The fourteen days, as one line.
///
/// Not a month of anonymous dots. The chain *is* the motto's fourteen days, so
/// the picture worth drawing is that period and where in it somebody stands —
/// four weeks backwards answers a question nobody asked and hides the one they
/// did: how far along am I, and what did I miss.
///
/// A missed day is drawn, not skipped. The streak is worth something because
/// the gaps show.
class ChainStrip extends StatelessWidget {
  const ChainStrip({
    required this.chain,
    required this.today,
    required this.streak,
    super.key,
  });

  static const int days = DailyAssembler.cycleDays;

  final Chain chain;
  final DateTime today;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final started = chain.startedOn;
    final start = started == null ? null : dayOf(started);
    final now = dayOf(today);
    final standing = start == null
        ? 0
        : (now.difference(start).inDays + 1).clamp(0, days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'ZİNCİR',
              style: text.labelMedium?.copyWith(
                letterSpacing: 1.3,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '$standing',
              style: text.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              ' / $days',
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var day = 0; day < days; day++) ...[
              if (day > 0) const SizedBox(width: 3),
              Expanded(
                child: _Day(
                  state: _stateOf(day, start: start, now: now),
                  scheme: scheme,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _caption(standing),
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  _DayState _stateOf(
    int offset, {
    required DateTime? start,
    required DateTime now,
  }) {
    if (start == null) return _DayState.ahead;

    final day = start.add(Duration(days: offset));
    if (chain.isMarked(day)) return _DayState.done;
    if (day == now) return _DayState.today;
    return day.isBefore(now) ? _DayState.missed : _DayState.ahead;
  }

  String _caption(int standing) {
    if (chain.startedOn == null) return 'Henüz başlamadı.';
    if (streak == 0) return 'Bugün işaretlenmedi.';
    return streak == standing ? 'Hiç kaçırmadın.' : '$streak gün üst üste.';
  }
}

enum _DayState { done, today, missed, ahead }

class _Day extends StatelessWidget {
  const _Day({required this.state, required this.scheme});

  final _DayState state;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // Height carries the state as well as colour, so the run reads as a shape
    // from across the room and not only to somebody who can tell two greens
    // apart.
    final tall = state == _DayState.done || state == _DayState.today;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: tall ? 22 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: switch (state) {
          _DayState.done => scheme.primary,
          _DayState.today => Colors.transparent,
          _DayState.missed => scheme.errorContainer,
          _DayState.ahead => scheme.surfaceContainerHighest,
        },
        border: state == _DayState.today
            ? Border.all(color: scheme.primary, width: 2)
            : null,
      ),
    );
  }
}
