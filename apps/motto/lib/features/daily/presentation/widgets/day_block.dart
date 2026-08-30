import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/presentation/widgets/motto_block.dart';
import 'package:motto/features/daily/presentation/widgets/tomorrow_line.dart';
import 'package:motto/features/daily/presentation/widgets/yesterday_line.dart';
import 'package:motto/features/support/presentation/widgets/could_not_load.dart';
import 'package:motto/route/app_router.gr.dart';

/// The motto and what today says about it — or why neither is there yet.
class DayBlock extends StatelessWidget {
  const DayBlock({required this.state, super.key});

  final DailyState state;

  @override
  Widget build(BuildContext context) => switch (state.status) {
    DailyStatus.noResultYet => const _NoResult(),
    DailyStatus.failed || DailyStatus.noContent => _Unavailable(
      status: state.status,
    ),
    _ when state.content == null => const _Waiting(),
    _ => _Ready(state: state),
  };
}

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('daily.inventoryFirst'.tr(), style: text.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'daily.inventoryBody'.tr(),
          style: text.bodyLarge,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => context.router.push(const QuestionRoute()),
          child: Text('daily.start'.tr()),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.status});

  final DailyStatus status;

  @override
  Widget build(BuildContext context) {
    return CouldNotLoad.inline(
      said: status == DailyStatus.noContent
          ? 'daily.neverDownloaded'.tr()
          : 'daily.failed'.tr(),
      retry: context.read<DailyCubit>().unawaitedLoad,
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: CircularProgressIndicator(),
    ),
  );
}

class _Ready extends StatelessWidget {
  const _Ready({required this.state});

  final DailyState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final content = state.content!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MottoBlock(motto: content.mottoLine),
        const SizedBox(height: 28),
        if (state.keptYesterday case final bool kept) ...[
          YesterdayLine(kept: kept),
          const SizedBox(height: 14),
        ],
        Text(
          'daily.dayLabel'.tr(namedArgs: {'day': '${content.day}'}),
          style: text.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(content.title, style: text.titleLarge),
        const SizedBox(height: 12),
        Text(content.text, style: text.bodyLarge),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content.action, style: text.bodyMedium),
        ),
        if (state.tomorrow case final String next) ...[
          const SizedBox(height: 28),
          TomorrowLine(title: next),
        ],
      ],
    );
  }
}
