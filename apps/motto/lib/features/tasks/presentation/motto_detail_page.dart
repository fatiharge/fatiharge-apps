import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/route/app_router.gr.dart';

/// The motto, at length, whenever someone wants it.
///
/// Separate from the card they shared: that one is a picture for a feed, this
/// one is the thing they came back to read.
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
                Text('“${content.motto}”', style: text.headlineSmall),
                const SizedBox(height: 24),
                Text(content.title, style: text.titleMedium),
                const SizedBox(height: 8),
                Text(content.text, style: text.bodyLarge),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(content.action, style: text.bodyMedium),
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
