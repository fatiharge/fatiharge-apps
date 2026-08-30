import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/theme/motto_loading.dart';

/// The free report: what the reader is, one dimension at a time.
///
/// Whole on purpose. It never mentions the deep report and never stops to ask
/// for money — a free report that trails off teaches people the paid one is
/// this text with the rest attached, and it is not.
@RoutePage()
class ReportPage extends StatefulWidget {
  const ReportPage({@PathParam('resultId') required this.resultId, super.key});

  final int resultId;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  api.ResultReport? _report;
  bool _failed = false;

  /// Named for the reader, not for the literature. "Nevrotiklik" is accurate
  /// and reads like a diagnosis.
  /// Read rather than held: a const map is filled once, and once is before
  /// the language is known.
  static Map<String, String> get _labels => {
    'OPENNESS': 'report.openness'.tr(),
    'CONSCIENTIOUSNESS': 'report.conscientiousness'.tr(),
    'EXTRAVERSION': 'report.extraversion'.tr(),
    'AGREEABLENESS': 'report.agreeableness'.tr(),
    'NEUROTICISM': 'report.neuroticism'.tr(),
  };

  static Map<String, String> get _bands => {
    'low': 'report.low'.tr(),
    'mid': 'report.mid'.tr(),
    'high': 'report.high'.tr(),
  };

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final report = await getIt<api.ReportResourceApi>().resultReport(
        widget.resultId,
      );
      if (mounted) setState(() => _report = report);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: Text('report.title'.tr())),
      body: SafeArea(
        child: switch ((report, _failed)) {
          (null, true) => Center(child: Text('report.failed'.tr())),
          (null, _) => const MottoLoading(),
          (final api.ResultReport ready, _) => _read(context, ready),
        },
      ),
    );
  }

  Widget _read(BuildContext context, api.ResultReport report) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        Text(report.overview, style: text.bodyLarge),
        const SizedBox(height: 32),
        Text(
          'report.axes'.tr(),
          style: text.labelMedium?.copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        for (final reading in report.readings) ...[
          _Reading(
            label: _labels[reading.dimension] ?? reading.dimension,
            band: _bands[reading.band] ?? reading.band,
            score: reading.score,
            text: reading.text,
          ),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 8),
        _Block(
          title: 'report.gives'.tr(),
          body: report.strength,
          colour: scheme.primaryContainer,
          onColour: scheme.onPrimaryContainer,
        ),
        const SizedBox(height: 12),
        // The cost sits in the free report rather than behind the paywall: a
        // profile that only flatters is the thing nobody comes back to.
        _Block(
          title: 'report.costs'.tr(),
          body: report.cost,
          colour: scheme.surfaceContainerHighest,
          onColour: scheme.onSurface,
        ),
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading({
    required this.label,
    required this.band,
    required this.score,
    required this.text,
  });

  final String label;
  final String band;
  final double score;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.titleMedium)),
            Text(
              band,
              style: theme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Drawn, not only asserted: somebody who can see where they sit on the
        // scale argues with the number instead of dismissing the sentence.
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.clamp(0, 1),
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 10),
        Text(text, style: theme.bodyMedium),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.body,
    required this.colour,
    required this.onColour,
  });

  final String title;
  final String body;
  final Color colour;
  final Color onColour;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleSmall?.copyWith(color: onColour)),
          const SizedBox(height: 8),
          Text(body, style: text.bodyLarge?.copyWith(color: onColour)),
        ],
      ),
    );
  }
}
