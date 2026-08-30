import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/support/application/support_copy_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

@RoutePage()
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<SupportCopyCubit>()..unawaitedLoad()),
      ],
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
      appBar: AppBar(title: Text('privacy.title'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Text('Veriler', style: text.titleMedium),
            const SizedBox(height: 12),
            BlocBuilder<SupportCopyCubit, SupportCopyState>(
              builder: (context, copy) {
                if (copy.copy == null) {
                  return Text(
                    copy.status == SupportCopyStatus.failed
                        ? 'privacy.failed'.tr()
                        : '…',
                    style: text.bodyMedium,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in copy.copy!.privacy) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: text.bodyMedium),
                          Expanded(child: Text(line, style: text.bodyMedium)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text('privacy.permissions'.tr(), style: text.titleMedium),
            const SizedBox(height: 12),
            BlocBuilder<ChainCubit, ChainState>(
              builder: (context, state) => Text(
                state.remindersAllowed
                    ? 'privacy.notificationsOn'.tr()
                    : 'privacy.notificationsOff'.tr(),
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.router.push(const DataDeletionRoute()),
              child: Text('privacy.deleteData'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
