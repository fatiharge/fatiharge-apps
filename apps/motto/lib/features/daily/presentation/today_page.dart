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
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/presentation/mascot.dart';
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
  MascotController? _mascot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugün'),
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ChainCubit, ChainState>(
          builder: (context, chainState) {
            final now = DateTime.now();

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Center(
                  child: Mascot(
                    onReady: (mascot) => _mascot = mascot,
                    onGameOffered: () => _offerGame(context),
                  ),
                ),
                const SizedBox(height: 16),
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
    await context.read<ChainCubit>().markToday();
    _mascot?.celebrate();
    // The day moves with the chain, so marking it is what makes tomorrow's
    // content tomorrow's.
    await daily.load();
  }

  // TODO(fcetin): open the sorting game — T28. The mascot already offers it.
  void _offerGame(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oyun yakında.')),
    );
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
