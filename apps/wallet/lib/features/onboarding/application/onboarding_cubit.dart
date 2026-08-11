import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

/// Walks the first-run steps and applies what the last one collects.
///
/// Language, theme and currency are not held here: each of those steps writes
/// through as it is tapped, so the app changes under the user rather than at
/// the end. Only the category picks need collecting, because archiving them
/// one tap at a time would fight the user's own back-and-forth.
@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._categories, this._settings)
    : super(const OnboardingState());

  final CategoryRepository _categories;
  final SettingsRepository _settings;

  Future<void> start() async {
    final categories = await _categories.fetchAll();
    emit(
      state.copyWith(
        categories: categories,
        keptCategoryIds: {
          for (final category in categories)
            if (!category.archived) category.id,
        },
      ),
    );
  }

  void next() {
    if (state.isLast) return;
    emit(
      state.copyWith(
        step: OnboardingStep.values[state.stepNumber],
      ),
    );
  }

  void back() {
    if (state.isFirst) return;
    emit(
      state.copyWith(
        step: OnboardingStep.values[state.stepNumber - 2],
      ),
    );
  }

  void toggleCategory(String id, {required bool keep}) {
    final kept = {...state.keptCategoryIds};
    if (keep) {
      kept.add(id);
    } else {
      kept.remove(id);
    }
    emit(state.copyWith(keptCategoryIds: kept));
  }

  /// Archives what was unticked, then records that the flow is done.
  ///
  /// Archiving rather than deleting is the whole point: a category dropped
  /// here is one tap away in settings, and any transaction that ever pointed
  /// at it still resolves.
  Future<void> finish() async {
    for (final category in state.categories) {
      if (!category.archived && !state.keptCategoryIds.contains(category.id)) {
        await _categories.archive(category.id);
      }
    }
    await _complete();
  }

  /// Leaves every default in place. The language, theme and currency steps
  /// have already written anything the user touched on the way past.
  Future<void> skip() => _complete();

  Future<void> _complete() async {
    await _settings.completeOnboarding();
    emit(state.copyWith(finished: true));
  }
}
