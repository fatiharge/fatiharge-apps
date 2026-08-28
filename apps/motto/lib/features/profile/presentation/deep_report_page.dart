import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/theme/motto_loading.dart';

/// The deep report, or the preview of one.
///
/// The locked state is not a teaser bolted on: it is the only thing someone
/// sees before paying, so it has to say what they would get without being it.
@RoutePage()
class DeepReportPage extends StatefulWidget {
  const DeepReportPage({
    @PathParam('resultId') required this.resultId,
    super.key,
  });

  final int resultId;

  @override
  State<DeepReportPage> createState() => _DeepReportPageState();
}

class _DeepReportPageState extends State<DeepReportPage> {
  api.DeepReport? _report;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final report = await getIt<api.ReportResourceApi>().deepReport(
        widget.resultId,
      );
      if (mounted) setState(() => _report = report);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: const Text('Derin rapor')),
      body: SafeArea(
        child: switch ((report, _failed)) {
          (null, true) => const Center(child: Text('Rapor alınamadı.')),
          (null, _) => const MottoLoading(),
          (final api.DeepReport ready, _) when ready.locked => _locked(
            context,
            ready,
            text,
            scheme,
          ),
          (final api.DeepReport ready, _) => _open(ready, text, scheme),
        },
      ),
    );
  }

  Widget _locked(
    BuildContext context,
    api.DeepReport report,
    TextTheme text,
    ColorScheme scheme,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        Text(report.preview, style: text.bodyLarge),
        const SizedBox(height: 8),
        // Faded rather than absent: what is behind the lock has to have a
        // shape, or the price is being asked for nothing anyone can picture.
        Opacity(
          opacity: 0.25,
          child: Column(
            children: [
              for (var line = 0; line < 6; line++)
                Container(
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Beş bölüm, senin profiline göre kuruluyor. Aynı arketipteki iki '
          'kişi aynı raporu okumuyor.',
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        // TODO(fcetin): open the paywall — T13.
        FilledButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alma yakında.')),
          ),
          child: const Text('Kilidi aç'),
        ),
      ],
    );
  }

  Widget _open(api.DeepReport report, TextTheme text, ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        if (report.portrait case final String portrait) ...[
          Text(portrait, style: text.bodyLarge),
          const SizedBox(height: 28),
        ],
        for (final section in report.sections) ...[
          Text(section.opening, style: text.titleMedium),
          const SizedBox(height: 8),
          Text(section.reading, style: text.bodyLarge),
          const SizedBox(height: 8),
          Text(section.fragment, style: text.bodyLarge),
          const SizedBox(height: 28),
        ],
        if (report.comparison case final String comparison) ...[
          Text(comparison, style: text.bodyLarge),
          const SizedBox(height: 28),
        ],
        if (report.limitation case final String limitation)
          Text(
            limitation,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
      ],
    );
  }
}
