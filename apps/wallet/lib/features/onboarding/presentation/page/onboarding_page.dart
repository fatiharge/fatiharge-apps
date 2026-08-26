import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/onboarding/application/onboarding_cubit.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/route/app_router.gr.dart';

@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // start() loads the seeded categories; the first steps do not need
    // them, so the screen opens without waiting.
    create: (_) {
      final cubit = getIt<OnboardingCubit>();
      // The first steps do not need the categories, so the screen opens
      // without waiting for them.
      unawaited(cubit.start());
      return cubit;
    },
    child: BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => !previous.finished && current.finished,
      // replaceAll, not push: there is nothing to come back to, and the flow
      // must not sit under the tabs waiting to be popped into.
      listener: (context, state) =>
          getIt<RouteManager>().replaceAll([const MainRoute()]),
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return Scaffold(
          body: OnboardingView(
            state: state,
            onNext: cubit.next,
            onBack: cubit.back,
            onSkip: cubit.skip,
            onFinish: cubit.finish,
            onToggleCategory: cubit.toggleCategory,
          ),
        );
      },
    ),
  );
}
