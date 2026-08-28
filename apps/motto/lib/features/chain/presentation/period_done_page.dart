import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/route/app_router.gr.dart';

/// The end of the fourteen days, and the way into the next.
///
/// This exists because the product had no ending. Day fifteen wrapped quietly
/// back to day one — the same texts, the same motto, nothing said. Everything
/// else here is built around fourteen: the content cycle, the cooldown, and
/// four mottos per archetype of which only the first was ever reachable.
@RoutePage()
class PeriodDonePage extends StatelessWidget {
  const PeriodDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<DailyCubit>()..unawaitedLoad()),
      ],
      child: const _PeriodDoneView(),
    );
  }
}

class _PeriodDoneView extends StatelessWidget {
  const _PeriodDoneView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Text('On dört gün bitti.', style: text.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Bir dönem tamamlandı. Devam etmeden önce raporunu oku — '
              'yaptığın şey orada sayılı.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.router.push(const PeriodReportRoute()),
              child: const Text('Dönem raporunu oku'),
            ),
            const SizedBox(height: 40),
            Divider(color: scheme.outlineVariant, height: 1),
            const SizedBox(height: 28),
            Text('Sırada ne var', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Arketipin değişmedi. Değişen, önümüzdeki on dört günü hangi '
              'cümlenin taşıyacağı.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            BlocBuilder<ChainCubit, ChainState>(
              builder: (context, chain) => BlocBuilder<DailyCubit, DailyState>(
                builder: (context, daily) => Column(
                  children: [
                    for (final motto in daily.pool)
                      _MottoChoice(
                        motto: motto,
                        current: _isCurrent(motto, chain, daily),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Null on the chain means the first, which is what every period before this
  /// one ran under.
  bool _isCurrent(PackMotto motto, ChainState chain, DailyState daily) =>
      chain.chain.mottoId == null
      ? daily.pool.isNotEmpty && daily.pool.first.id == motto.id
      : chain.chain.mottoId == motto.id;
}

class _MottoChoice extends StatelessWidget {
  const _MottoChoice({required this.motto, required this.current});

  final PackMotto motto;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _begin(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: current ? Border.all(color: scheme.primary) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (current) ...[
                Text(
                  'ŞU ANKİ',
                  style: text.labelSmall?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text('“${motto.motto}”', style: text.titleMedium),
              const SizedBox(height: 8),
              Text(
                motto.detail,
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _begin(BuildContext context) async {
    await context.read<ChainCubit>().beginNextPeriod(mottoId: motto.id);
    if (context.mounted) await context.router.maybePop();
  }
}
