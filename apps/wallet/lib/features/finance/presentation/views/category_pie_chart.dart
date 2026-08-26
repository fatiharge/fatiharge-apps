import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Slices below a minimum share are folded into a single "other" slice —
/// a dozen 1% slivers are unreadable and unclickable.
class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    required this.breakdown,
    required this.total,
    required this.categories,
    super.key,
  });

  final List<CategoryTotal> breakdown;
  final Money total;
  final Map<String, Category> categories;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  static const double _minSharePercent = 3;
  static const Color _otherColor = Color(0xFF9E9E9E);

  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.breakdown.isEmpty || widget.total.isZero) {
      return Card(
        child: SizedBox(
          height: 240,
          child: EmptyState(
            icon: Icons.pie_chart_outline,
            title: context.tr(LocaleKeys.dashboard_no_expenses),
          ),
        ),
      );
    }

    final slices = _slices();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(LocaleKeys.dashboard_by_category),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      _section(slices[i], isTouched: i == _touchedIndex),
                  ],
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) => setState(() {
                      _touchedIndex = event.isInterestedForInteractions
                          ? response?.touchedSection?.touchedSectionIndex
                          : null;
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final slice in slices) _LegendRow(slice: slice),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(_Slice slice, {required bool isTouched}) =>
      PieChartSectionData(
        value: slice.share,
        color: slice.color,
        title: '${slice.share.toStringAsFixed(0)}%',
        radius: isTouched ? 62 : 54,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  List<_Slice> _slices() {
    final total = widget.total.amountMinor;
    final slices = <_Slice>[];
    var otherMinor = 0;

    for (final entry in widget.breakdown) {
      final share = entry.total.amountMinor / total * 100;
      final category = widget.categories[entry.categoryId];
      if (share < _minSharePercent) {
        otherMinor += entry.total.amountMinor;
        continue;
      }
      slices.add(
        _Slice(
          label: category?.displayName(context) ?? entry.categoryId,
          amount: entry.total,
          share: share,
          color: category == null ? _otherColor : Color(category.colorArgb),
        ),
      );
    }

    if (otherMinor > 0) {
      slices.add(
        _Slice(
          label: context.tr(LocaleKeys.dashboard_other_categories),
          amount: Money(otherMinor, widget.total.currency),
          share: otherMinor / total * 100,
          color: _otherColor,
        ),
      );
    }
    return slices;
  }
}

class _Slice {
  const _Slice({
    required this.label,
    required this.amount,
    required this.share,
    required this.color,
  });

  final String label;
  final Money amount;
  final double share;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice});

  final _Slice slice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: slice.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              slice.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            slice.amount.format(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
