import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/presentation/mascot_free_zone.dart';
import 'package:motto/features/test/application/test_cubit.dart';
import 'package:motto/features/test/application/test_state.dart';
import 'package:motto/features/test/presentation/widgets/glimpse_sheet.dart';
import 'package:motto/features/test/presentation/widgets/likert_scale.dart';
import 'package:motto/features/test/presentation/widgets/test_progress.dart';
import 'package:motto/route/app_router.gr.dart';

/// One template, asked as many times as there are questions.
///
/// No navigation bar anywhere in this flow: completion is the only thing that
/// matters here, and every tab in a bottom bar is a way out of it.
@RoutePage()
class QuestionPage extends StatelessWidget implements AutoRouteWrapper {
  const QuestionPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MascotFreeZone(
    child: BlocProvider(
      create: (_) => getIt<TestCubit>()..unawaitedStart(),
      child: this,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TestCubit, TestState>(
      listenWhen: (previous, current) =>
          previous.glimpse != current.glimpse ||
          previous.isFinished != current.isFinished,
      listener: (context, state) {
        if (state.glimpse != null) {
          _showGlimpse(context, state);
        } else if (state.isFinished) {
          unawaited(context.router.replace(const CalculatingRoute()));
        }
      },
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: switch (state.status) {
            TestStatus.loading || TestStatus.idle => const Center(
              child: CircularProgressIndicator(),
            ),
            TestStatus.failed => _Failed(
              onRetry: context.read<TestCubit>().unawaitedStart,
            ),
            _ => _Asking(state: state),
          },
        ),
      ),
    );
  }

  void _showGlimpse(BuildContext context, TestState state) {
    final cubit = context.read<TestCubit>();
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => GlimpseSheet(
          archetype: state.glimpse!,
          onContinue: () => Navigator.of(sheetContext).pop(),
        ),
      ).whenComplete(cubit.dismissGlimpse),
    );
  }
}

class _Asking extends StatelessWidget {
  const _Asking({required this.state});

  final TestState state;

  @override
  Widget build(BuildContext context) {
    final question = state.current;
    if (question == null) return const SizedBox.shrink();

    final cubit = context.read<TestCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TestProgress(value: state.progress),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: state.index == 0 ? null : cubit.back,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weighted rather than even: a question floating in the
                // middle of an empty screen reads as a page that failed to
                // load, and the scale is what the thumb is reaching for.
                const Spacer(flex: 2),
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(flex: 3),
                LikertScale(
                  selected: state.answers[question.id],
                  onSelected: cubit.answer,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sorular yüklenemedi.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}
