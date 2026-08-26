import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// An enum, not an `IconData`: the domain stays Flutter-free, and a non-const
/// `IconData` would break icon tree-shaking.
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

/// Never hard-deleted — past transactions keep pointing at them — so removal
/// is the [archived] flag.
///
/// [name] and [nameKey] are exclusive: a key follows the app language, a name
/// is the user's own and must survive a language switch.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required CategoryIcon icon,
    required int colorArgb,
    String? name,
    String? nameKey,
    @Default(false) bool archived,
  }) = _Category;
}
