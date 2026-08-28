import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/route/app_router.gr.dart';

/// What somebody has, and what today says about it.
///
/// Only those two. The chain and the three things live in Görevler, next to
/// each other, because marking the day and doing the day are the same act —
/// and a screen carrying the motto, the day, the run and a button reads as
/// four screens stacked, with the motto losing.
@RoutePage()
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DailyCubit>()..unawaitedLoad()),
      ],
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatefulWidget {
  const _TodayView();

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // No settings action: settings is a tab now, and two ways to the same
      // screen is one more thing to keep in step.
      appBar: AppBar(title: const Text('Bugün')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
          children: [
            // The motto and the day, and nothing else. The chain moved to
            // Görevler, next to the three things that advance it: this screen
            // is what somebody reads, that one is what they do.
            BlocBuilder<DailyCubit, DailyState>(
              builder: (context, daily) => _day(context, daily, text, scheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _day(
    BuildContext context,
    DailyState state,
    TextTheme text,
    ColorScheme scheme,
  ) {
    if (state.status == DailyStatus.noResultYet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Önce envanteri doldur', style: text.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Günlük içerik arketibine göre kuruluyor. Ondan önce sana '
            'söylenecek kişisel bir şey yok.',
            style: text.bodyLarge,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.router.push(const QuestionRoute()),
            child: const Text('Başla'),
          ),
        ],
      );
    }

    if (state.status == DailyStatus.failed ||
        state.status == DailyStatus.noContent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.status == DailyStatus.noContent
                  ? 'Günlük içerik bu cihaza hiç inmedi. Bağlantını kontrol '
                        'edip tekrar dene.'
                  : 'Bugünün metni açılamadı. Tekrar dene.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<DailyCubit>().unawaitedLoad(),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    final content = state.content;
    if (content == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The motto first. It is what somebody has, and the day is what the
        // app suggests about it — the other way round buries the thing they
        // came back for under this morning's advice.
        InkWell(
          onTap: () => context.router.push(const MottoDetailRoute()),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MOTTON',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content.motto,
                  style: text.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // What happened before today. One line, and only once the chain has
        // started — a screen that opens the same way on day one and day nine
        // is a screen nobody is inside of.
        if (state.keptYesterday case final bool kept) ...[
          Row(
            children: [
              Icon(
                kept ? Icons.check_circle_outline : Icons.remove_circle_outline,
                size: 16,
                color: kept ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                kept ? 'Dün işaretledin.' : 'Dün kaçtı.',
                style: text.bodyMedium?.copyWith(
                  color: kept ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Text(
          '${content.day}. GÜN',
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
        // And what is waiting. Named rather than teased: "yarın bir sürprizin
        // var" is the sentence people learn to ignore.
        if (state.tomorrow case final String next) ...[
          const SizedBox(height: 28),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'YARIN',
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  next,
                  style: text.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// The hour is asked for rather than assumed: a reminder at the wrong time
  /// of day is the one that teaches people to swipe them away.
}
