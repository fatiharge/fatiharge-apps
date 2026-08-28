import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/route/app_router.gr.dart';

/// The motto itself — what it means, what it costs, and what it will say.
///
/// It used to repeat Bugün: the same title, the same day text, the same
/// action, with the motto quoted on top. A screen whose only reason to exist
/// was the button at the bottom. What belongs here was already written and had
/// never been drawn — every motto carries a reading and a reminder line, and
/// the app was parsing both and showing neither.
@RoutePage()
class MottoDetailPage extends StatelessWidget {
  const MottoDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DailyCubit>()..unawaitedLoad(),
      child: const _MottoDetailView(),
    );
  }
}

class _MottoDetailView extends StatelessWidget {
  const _MottoDetailView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mottonun')),
      body: SafeArea(
        child: BlocBuilder<DailyCubit, DailyState>(
          builder: (context, state) {
            final content = state.content;
            if (content == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Text(
                  '“${content.mottoLine}”',
                  style: text.headlineSmall?.copyWith(height: 1.25),
                ),
                const SizedBox(height: 28),
                Text(
                  'NE DEMEK',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(content.motto.detail, style: text.bodyLarge),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HER GÜN ŞUNU DUYACAKSIN',
                            style: text.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(content.motto.reminder, style: text.titleSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () =>
                      context.router.push(const PeriodReportRoute()),
                  child: const Text('Dönem raporu'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
