import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/support/domain/privacy_text.dart';
import 'package:motto/route/app_router.gr.dart';

@RoutePage()
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChainCubit>()..unawaitedLoad(),
      child: const _PrivacyView(),
    );
  }
}

class _PrivacyView extends StatelessWidget {
  const _PrivacyView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik ve izinler')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Text('Veriler', style: text.titleMedium),
            const SizedBox(height: 12),
            for (final line in privacySummary) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: text.bodyMedium),
                  Expanded(child: Text(line, style: text.bodyMedium)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
            Text('İzinler', style: text.titleMedium),
            const SizedBox(height: 12),
            BlocBuilder<ChainCubit, ChainState>(
              builder: (context, state) => Text(
                state.remindersAllowed
                    ? 'Bildirimler açık.'
                    : 'Bildirimler kapalı. Zincir yine de işliyor; günü kendin '
                          'işaretlersin.',
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.router.push(const DataDeletionRoute()),
              child: const Text('Verilerimi sil'),
            ),
          ],
        ),
      ),
    );
  }
}
