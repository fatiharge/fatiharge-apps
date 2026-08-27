import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';

/// What fourteen days came to.
@RoutePage()
class PeriodReportPage extends StatefulWidget {
  const PeriodReportPage({super.key});

  @override
  State<PeriodReportPage> createState() => _PeriodReportPageState();
}

class _PeriodReportPageState extends State<PeriodReportPage> {
  api.PeriodReport? _report;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final now = DateTime.now();
    try {
      final report = await getIt<api.TaskResourceApi>().periodReport(
        today: DateTime(now.year, now.month, now.day),
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
      appBar: AppBar(title: const Text('Dönem raporu')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: switch ((report, _failed)) {
            (null, true) => const Text('Rapor alınamadı.'),
            (null, _) => const Center(child: CircularProgressIndicator()),
            (final api.PeriodReport ready, _) => ListView(
              children: [
                Text(
                  ready.complete
                      ? 'On dört gün bitti'
                      : '${ready.day}. gündesin',
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 24),
                _Line(
                  label: 'İşaretlenen gün',
                  value: '${ready.daysMarked} / 14',
                ),
                if (ready.daysMadeUp > 0)
                  _Line(
                    label: 'Bunların telafiyle gelen',
                    value: '${ready.daysMadeUp}',
                  ),
                _Line(
                  label: 'Yapılan görev',
                  value: '${ready.tasksDone} / ${ready.tasksOffered}',
                ),
                const SizedBox(height: 32),
                Text(
                  ready.complete
                      ? 'Bundan sonra devam eden şey artık bir deneme değil, '
                            'senin yaptığın bir şey.'
                      : 'Dönem sürüyor. Rapor her gün biraz daha doluyor.',
                  style: text.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text.bodyLarge),
          Text(value, style: text.titleMedium),
        ],
      ),
    );
  }
}
