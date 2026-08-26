import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

/// Only the category picks are collected. Language, theme and currency write
/// through as they are tapped, so the app changes under the user.
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

  /// Archived, not deleted: it stays one tap away in settings, and any
  /// transaction pointing at it still resolves.
  Future<void> finish() async {
    for (final category in state.categories) {
      if (!category.archived && !state.keptCategoryIds.contains(category.id)) {
        await _categories.archive(category.id);
      }
    }
    await _complete();
  }

  /// Leaves the defaults; the earlier steps already wrote what was touched.
  Future<void> skip() => _complete();

  Future<void> _complete() async {
    await _settings.completeOnboarding();
    emit(state.copyWith(finished: true));
  }
}
