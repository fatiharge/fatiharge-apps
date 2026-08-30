import 'package:api_client_motto/api.dart' as api;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/daily/domain/daily_assembler.dart';

/// One run of fourteen, drawn as the fourteen boxes the app already uses.
///
/// The same motif as the strip on Görevler on purpose: this screen is that
/// strip with its history behind it, and a second visual language for the same
/// idea would make them look like two different things.
class PeriodGrid extends StatelessWidget {
  const PeriodGrid({
    required this.period,
    required this.onDay,
    super.key,
  });

  final api.ChainPeriod period;

  /// Called with the position of the day in the run, counting from one — which
  /// is also which of the fourteen texts that day carried.
  final void Function(int place) onDay;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final days = period.days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'days.periodLabel'.tr(namedArgs: {'period': '${period.period}'}),
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              period.current
                  ? 'days.periodRunning'.tr(
                      namedArgs: {
                        'done': '${days.length}',
                        'of': '${DailyAssembler.cycleDays}',
                      },
                    )
                  : 'periodReport.outOf'.tr(
                      namedArgs: {
                        'done': '${days.length}',
                        'of': '${DailyAssembler.cycleDays}',
                      },
                    ),
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var place = 1; place <= DailyAssembler.cycleDays; place++)
              _Box(
                day: place <= days.length ? days[place - 1] : null,
                place: place,
                onTap: place <= days.length ? () => onDay(place) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.day, required this.place, this.onTap});

  final api.MarkedDay? day;
  final int place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final marked = day != null;
    // A made-up day counts, and saying so is the point: a report that draws it
    // the same as a day somebody actually did is flattering rather than useful.
    final madeUp = day?.madeUp ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: marked && !madeUp ? scheme.primary : scheme.surface,
          border: Border.all(
            color: marked ? scheme.primary : scheme.outlineVariant,
            width: madeUp ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$place',
          style: text.labelMedium?.copyWith(
            color: marked && !madeUp
                ? scheme.onPrimary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
