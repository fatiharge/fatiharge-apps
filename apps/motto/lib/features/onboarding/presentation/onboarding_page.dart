import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/features/onboarding/application/onboarding_store.dart';
import 'package:motto/route/app_router.gr.dart';

/// What the app is, said once, by the thing that will keep saying it.
///
/// The mascot walks between the steps rather than sitting still: it is the
/// only part of this screen that is not text, and a mascot introduced as
/// scenery stays scenery.
@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({this.onDone, super.key});

  /// Where it goes when it is over. Injectable so the flow can be asserted
  /// without a router in the tree — leaving is the point of this screen.
  final Future<void> Function(BuildContext context, {required bool takeTest})?
  onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingStep {
  const _OnboardingStep(this.spot, this.title, this.body);

  final MascotSpot spot;
  final String title;
  final String body;
}

/// Read rather than held: a `const` list is built once, and once is before
/// anybody has said which language they read in.
List<_OnboardingStep> get _steps => [
  _OnboardingStep(
    MascotSpot.centre,
    'onboarding.hello'.tr(),
    'onboarding.inventory.body'.tr(),
  ),
  _OnboardingStep(
    MascotSpot.topLeft,
    'onboarding.daily.title'.tr(),
    'onboarding.daily.body'.tr(),
  ),
  _OnboardingStep(
    MascotSpot.topRight,
    'onboarding.mascot.title'.tr(),
    'onboarding.mascot.body'.tr(),
  ),
];

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _moveMascot());
  }

  void _moveMascot() {
    final move = MascotHost.movementOf(context);
    if (move == null) return;
    unawaited(move(_steps[_step].spot));
  }

  Future<void> _next() async {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      _moveMascot();
      return;
    }

    await getIt<OnboardingStore>().markSeen();
    if (!mounted) return;

    final move = MascotHost.movementOf(context);
    unawaited(move?.call(MascotSpot.home));
    await _leave(takeTest: true);
  }

  Future<void> _skip() async {
    await getIt<OnboardingStore>().markSeen();
    if (!mounted) return;
    await _leave(takeTest: false);
  }

  Future<void> _leave({required bool takeTest}) async {
    final leave = widget.onDone ?? _replaceRoute;
    await leave(context, takeTest: takeTest);
  }

  Future<void> _replaceRoute(
    BuildContext context, {
    required bool takeTest,
  }) => context.router.replaceAll([
    if (takeTest) const QuestionRoute() else const ShellRoute(),
  ]);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final step = _steps[_step];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text('onboarding.skip'.tr()),
                ),
              ),
              // Room for the mascot to move through, but not half a screen of
              // it: an empty upper half reads as a page that failed to load.
              const Spacer(flex: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Column(
                  key: ValueKey(_step),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: text.headlineSmall),
                    const SizedBox(height: 12),
                    Text(step.body, style: text.bodyLarge),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    Container(
                      width: i == _step ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _step
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _next,
                child: Text(
                  _step == _steps.length - 1
                      ? 'onboarding.start'.tr()
                      : 'Devam',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
