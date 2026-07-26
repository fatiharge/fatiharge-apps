import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// The icon a category is drawn with.
///
/// An enum rather than an `IconData` code point on purpose: the domain must
/// stay Flutter-free, and non-const `IconData` would break icon tree-shaking.
/// The presentation layer maps these to concrete icons.
enum CategoryIcon {
  food,
  transport,
  home,
  bills,
  health,
  shopping,
  entertainment,
  education,
  travel,
  salary,
  gift,
  savings,
  other,
}

/// A spending/earning category.
///
/// Categories are never hard-deleted: past transactions keep pointing at them,
/// so removal is an [archived] flag. Archived categories disappear from
/// pickers but historical records still resolve their name and colour.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required CategoryIcon icon,
    required int colorArgb,
    @Default(false) bool archived,
  }) = _Category;
}
