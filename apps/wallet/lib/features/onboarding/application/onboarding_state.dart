import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';

part 'onboarding_state.freezed.dart';

/// The steps, in order. Language before the rest so everything after it is
/// read in the language just picked.
enum OnboardingStep {
  welcome,
  language,
  theme,
  currency,
  categories,
  reminder,
}

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingStep.welcome) OnboardingStep step,

    /// Seeded by bootstrap before this screen opens.
    @Default(<Category>[]) List<Category> categories,

    /// Everything starts ticked; unticking is the user saying "not this one".
    @Default(<String>{}) Set<String> keptCategoryIds,
    @Default(false) bool finished,
  }) = _OnboardingState;

  const OnboardingState._();

  bool get isFirst => step == OnboardingStep.welcome;

  bool get isLast => step == OnboardingStep.values.last;

  int get stepNumber => OnboardingStep.values.indexOf(step) + 1;

  int get stepCount => OnboardingStep.values.length;
}
