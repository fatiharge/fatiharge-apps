import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/presentation/widgets/chain_calendar.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/route/app_router.gr.dart';

/// One screen and one scroll. The calendar is under the day rather than behind
/// a tab, because a tab is a place people do not go and the run is the part
/// that makes the day worth marking.
@RoutePage()
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
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
        child: BlocBuilder<ChainCubit, ChainState>(
          builder: (context, chainState) {
            final now = DateTime.now();

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                BlocBuilder<DailyCubit, DailyState>(
                  builder: (context, daily) => _standing(
                    context,
                    hasResult: daily.status != DailyStatus.noResultYet,
                    chainStarted: chainState.chain.started,
                    streak: chainState.streakToday(now),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<DailyCubit, DailyState>(
                  builder: (context, daily) =>
                      _day(context, daily, text, scheme),
                ),
                const SizedBox(height: 32),
                if (!chainState.chain.started)
                  FilledButton(
                    onPressed: () => _askHourThenStart(context),
                    child: const Text('Zincirini başlat'),
                  )
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${chainState.streakToday(now)}',
                        style: text.displaySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'gün',
                        style: text.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (chainState.canFreeze(now)) ...[
                    Text(
                      'Bir gün kaçtı. Telafi hakkın duruyor.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.read<ChainCubit>().useFreeze(),
                      child: const Text('Telafi et'),
                    ),
                    TextButton(
                      onPressed: () => context.router.push(
                        FaqRoute(openItem: 'chain_broken'),
                      ),
                      child: const Text('Telafi nasıl çalışıyor?'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: chainState.markedToday(now)
                        ? null
                        : () => _mark(context),
                    child: Text(
                      chainState.markedToday(now)
                          ? 'Bugün işaretlendi'
                          : 'Bugünü işaretle',
                    ),
                  ),
                  if (!chainState.remindersAllowed) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hatırlatıcılar kapalı. Zincir yine de işliyor.',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Text(
                    'Son dört hafta',
                    style: text.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChainCalendar(chain: chainState.chain, today: now),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Where someone stands, in two chips. Without it the screen is a wall of
  /// text that reads the same on day one and day thirty.
  Widget _standing(
    BuildContext context, {
    required bool hasResult,
    required bool chainStarted,
    required int streak,
  }) {
    return Wrap(
      spacing: 8,
      children: [
        _Chip(
          done: hasResult,
          label: hasResult ? 'Envanter tamam' : 'Envanter bekliyor',
        ),
        _Chip(
          done: chainStarted,
          label: chainStarted ? '$streak günlük zincir' : 'Zincir başlamadı',
        ),
      ],
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
        Text(
          '${content.day}. GÜN',
          style: text.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(content.title, style: text.headlineSmall),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        Text(
          '“${content.motto}”',
          style: text.titleMedium?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }

  Future<void> _mark(BuildContext context) async {
    final daily = context.read<DailyCubit>();
    final mascot = MascotHost.of(context);
    await context.read<ChainCubit>().markToday();
    mascot?.celebrate();
    // The day moves with the chain, so marking it is what makes tomorrow's
    // content tomorrow's.
    await daily.load();
  }


  /// The hour is asked for rather than assumed: a reminder at the wrong time
  /// of day is the one that teaches people to swipe them away.
  Future<void> _askHourThenStart(BuildContext context) async {
    final cubit = context.read<ChainCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: ChainStore.defaultHour, minute: 0),
    );
    if (picked == null) return;

    await cubit.start(hour: picked.hour);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: done
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: done ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: done ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
