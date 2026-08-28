import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
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
        BlocProvider(create: (_) => getIt<ProfileCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
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
            // Above everything when the run is over: fourteen days finished is
            // the most important thing this screen can say, and it used to say
            // nothing at all.
            BlocBuilder<ChainCubit, ChainState>(
              builder: (context, chain) => chain.chain.periodDone
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: _PeriodDoneBanner(),
                    )
                  : const SizedBox.shrink(),
            ),
            // The motto and the day, and nothing else. The chain moved to
            // Görevler, next to the three things that advance it: this screen
            // is what somebody reads, that one is what they do.
            BlocBuilder<DailyCubit, DailyState>(
              builder: (context, daily) => _day(context, daily, text, scheme),
            ),
            // The way to the result, and through it to the deep report. It was
            // reachable only from the profile, which is the tab people open
            // last — a paid thing nobody can find is not a paid thing.
            //
            // From the server when it answers, from the package and what this
            // device remembers when it does not: the door to the paid thing
            // should not close because the train went into a tunnel.
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profile) =>
                  BlocBuilder<DailyCubit, DailyState>(
                    builder: (context, daily) {
                      final row = _row(profile, daily);
                      return row == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: row,
                            );
                    },
                  ),
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
                  content.mottoLine,
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
}

/// Who somebody is, one row, opening the result.
/// The server's answer if there is one, otherwise what the package and this
/// device already hold.
Widget? _row(ProfileState profile, DailyState daily) {
  if (profile.current case final api.ResultSummary result) {
    return _ArchetypeRow(
      name: result.archetype.name,
      archetype: result.archetype,
      resultId: result.id,
    );
  }
  if (daily.mine case final PackArchetype mine) {
    if (daily.resultId case final int id) {
      return _ArchetypeRow(
        name: mine.name,
        archetype: api.ArchetypeResponse(
          id: mine.id,
          name: mine.name,
          summary: mine.summary,
          motto: mine.motto,
          confident: true,
        ),
        resultId: id,
      );
    }
  }
  return null;
}

class _ArchetypeRow extends StatelessWidget {
  const _ArchetypeRow({
    required this.name,
    required this.archetype,
    required this.resultId,
  });

  final String name;
  final api.ArchetypeResponse archetype;
  final int resultId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.router.push(
        ResultRoute(archetype: archetype, resultId: resultId),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARKETİPİN',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(name, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Raporun ve derin raporun burada.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PeriodDoneBanner extends StatelessWidget {
  const _PeriodDoneBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.router.push(const PeriodDoneRoute()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On dört gün bitti.',
                    style: text.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Raporunu oku, sonra devam et.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}
