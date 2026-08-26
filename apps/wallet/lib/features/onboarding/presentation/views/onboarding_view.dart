import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/onboarding/presentation/views/onboarding_category_step.dart';
import 'package:wallet/features/settings/presentation/views/currency_section.dart';
import 'package:wallet/features/settings/presentation/views/language_section.dart';
import 'package:wallet/features/settings/presentation/views/reminder_section.dart';
import 'package:wallet/features/settings/presentation/views/theme_section.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/theme/app_mark.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onFinish,
    required this.onToggleCategory,
    super.key,
  });

  final OnboardingState state;

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onFinish;
  final void Function(String id, {required bool keep}) onToggleCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          _Progress(state: state, onSkip: onSkip),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.step == OnboardingStep.welcome) ...[
                    const SizedBox(height: 24),
                    const Center(child: AppMark(size: 96)),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    _title(context),
                    style: theme.textTheme.headlineSmall,
                    textAlign: state.step == OnboardingStep.welcome
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                  if (_message(context) case final message?) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: state.step == OnboardingStep.welcome
                          ? TextAlign.center
                          : TextAlign.start,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _body(),
                ],
              ),
            ),
          ),
          _Actions(
            state: state,
            onNext: onNext,
            onBack: onBack,
            onSkip: onSkip,
            onFinish: onFinish,
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) => switch (state.step) {
    OnboardingStep.welcome => context.tr(LocaleKeys.onboarding_welcome_title),
    OnboardingStep.language => context.tr(LocaleKeys.onboarding_language_title),
    OnboardingStep.theme => context.tr(LocaleKeys.onboarding_theme_title),
    OnboardingStep.currency => context.tr(LocaleKeys.onboarding_currency_title),
    OnboardingStep.categories => context.tr(
      LocaleKeys.onboarding_categories_title,
    ),
    OnboardingStep.reminder => context.tr(
      LocaleKeys.onboarding_reminder_title,
    ),
  };

  String? _message(BuildContext context) => switch (state.step) {
    OnboardingStep.welcome => context.tr(LocaleKeys.onboarding_welcome_message),
    OnboardingStep.currency => context.tr(LocaleKeys.settings_currency_hint),
    OnboardingStep.categories => context.tr(
      LocaleKeys.onboarding_categories_message,
    ),
    OnboardingStep.reminder => context.tr(
      LocaleKeys.onboarding_reminder_message,
    ),
    _ => null,
  };

  Widget _body() => switch (state.step) {
    OnboardingStep.welcome => const SizedBox.shrink(),
    OnboardingStep.language => const LanguageSection(),
    OnboardingStep.theme => const ThemeSection(),
    OnboardingStep.currency => const CurrencySection(),
    OnboardingStep.categories => OnboardingCategoryStep(
      categories: state.categories,
      keptIds: state.keptCategoryIds,
      onToggle: onToggleCategory,
    ),
    // Off unless the user turns it on: the platform prompt is one shot, and
    // spending it on someone with no data yet wastes it.
    OnboardingStep.reminder => const ReminderSection(),
  };
}

class _Progress extends StatelessWidget {
  const _Progress({required this.state, required this.onSkip});

  final OnboardingState state;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(
                  LocaleKeys.onboarding_step,
                  namedArgs: {
                    'current': '${state.stepNumber}',
                    'total': '${state.stepCount}',
                  },
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              // Always reachable, on every step: five screens before the app
              // is worth more than nothing to someone who wants to get on
              // with it.
              TextButton(
                onPressed: state.finished ? null : onSkip,
                child: Text(context.tr(LocaleKeys.onboarding_skip)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.stepNumber / state.stepCount,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onFinish,
  });

  final OnboardingState state;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Row(
      children: [
        if (!state.isFirst)
          TextButton(
            onPressed: onBack,
            child: Text(context.tr(LocaleKeys.onboarding_back)),
          ),
        const Spacer(),
        FilledButton(
          onPressed: state.isLast ? onFinish : onNext,
          child: Text(
            state.isLast
                ? context.tr(LocaleKeys.onboarding_start)
                : context.tr(LocaleKeys.onboarding_next),
          ),
        ),
      ],
    ),
  );
}
