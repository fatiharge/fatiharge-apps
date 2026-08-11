import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';

part 'category_state.freezed.dart';

/// The category management screen.
@freezed
abstract class CategoryState with _$CategoryState {
  const factory CategoryState({
    /// Storage order, archived ones included — the screen shows both, in two
    /// sections.
    @Default(<Category>[]) List<Category> categories,
    @Default(true) bool loading,
  }) = _CategoryState;

  const CategoryState._();

  List<Category> get active => [
    for (final category in categories)
      if (!category.archived) category,
  ];

  List<Category> get archived => [
    for (final category in categories)
      if (category.archived) category,
  ];

  bool get isEmpty => categories.isEmpty;
}
