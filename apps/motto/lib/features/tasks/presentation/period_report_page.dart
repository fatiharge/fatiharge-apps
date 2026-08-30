import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/domain/chain.dart';

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
    try {
      final report = await getIt<api.TaskResourceApi>().periodReport(
        today: isoDay(DateTime.now()),
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
      appBar: AppBar(title: Text('periodReport.title'.tr())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: switch ((report, _failed)) {
            (null, true) => Text('periodReport.failed'.tr()),
            (null, _) => const Center(child: CircularProgressIndicator()),
            (final api.PeriodReport ready, _) => ListView(
              children: [
                Text(
                  ready.complete
                      ? 'periodReport.complete'.tr()
                      : 'periodReport.onDay'.tr(
                          namedArgs: {'day': '${ready.day}'},
                        ),
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 24),
                _Line(
                  label: 'periodReport.markedDays'.tr(),
                  value: 'periodReport.outOf'.tr(
                    namedArgs: {'done': '${ready.daysMarked}', 'of': '14'},
                  ),
                ),
                if (ready.daysMadeUp > 0)
                  _Line(
                    label: 'periodReport.madeUp'.tr(),
                    value: '${ready.daysMadeUp}',
                  ),
                _Line(
                  label: 'periodReport.tasksDone'.tr(),
                  value: 'periodReport.outOf'.tr(
                    namedArgs: {
                      'done': '${ready.tasksDone}',
                      'of': '${ready.tasksOffered}',
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  ready.complete
                      ? 'periodReport.closing'.tr()
                      : 'periodReport.running'.tr(),
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
