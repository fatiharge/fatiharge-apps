import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/route/app_router.gr.dart';

/// The chain: start it, mark today, keep it.
///
/// Deliberately plain. The daily content screen is where this ends up living,
/// and building a home for it twice would be building it twice — what this
/// needs to do now is let the mechanic be used, because the fourteen days it
/// has to be tested for cannot start until it can.
@RoutePage()
class ChainPage extends StatelessWidget {
  const ChainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChainCubit>()..unawaitedLoad(),
      child: const _ChainView(),
    );
  }
}

class _ChainView extends StatelessWidget {
  const _ChainView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zincir'),
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ChainCubit, ChainState>(
          builder: (context, state) {
            final now = DateTime.now();

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!state.chain.started)
                    ..._start(context, text)
                  else ...[
                    Text('${state.streakToday(now)}', style: text.displayLarge),
                    Text(
                      'gün',
                      style: text.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (state.canFreeze(now)) ..._freeze(context, text),
                    if (!state.remindersAllowed) ...[
                      Text(
                        'Hatırlatıcılar kapalı. Zincir yine de işliyor.',
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Spacer(),
                    FilledButton(
                      onPressed: state.markedToday(now)
                          ? null
                          : () => context.read<ChainCubit>().markToday(),
                      child: Text(
                        state.markedToday(now)
                            ? 'Bugün işaretlendi'
                            : 'Bugünü işaretle',
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _start(BuildContext context, TextTheme text) => [
    const Spacer(),
    Text('Zincirini başlat', style: text.headlineSmall),
    const SizedBox(height: 12),
    Text(
      'Her gün bir dakika. Hangi saatte hatırlatalım?',
      style: text.bodyLarge,
    ),
    const Spacer(),
    FilledButton(
      onPressed: () => _askHourThenStart(context),
      child: const Text('Başlat'),
    ),
  ];

  List<Widget> _freeze(BuildContext context, TextTheme text) => [
    Text('Bir gün kaçtı. Telafi hakkın duruyor.', style: text.bodyLarge),
    const SizedBox(height: 12),
    OutlinedButton(
      onPressed: () => context.read<ChainCubit>().useFreeze(),
      child: const Text('Telafi et'),
    ),
    // Straight to the entry, not to a list someone then has to search: the
    // question is already formed by the time they get here.
    TextButton(
      onPressed: () =>
          context.router.push(FaqRoute(openItem: 'chain_broken')),
      child: const Text('Telafi nasıl çalışıyor?'),
    ),
    const SizedBox(height: 24),
  ];

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
