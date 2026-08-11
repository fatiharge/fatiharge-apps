import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The categories a fresh install starts with.
///
/// Feature content, so it lives with the feature rather than under
/// `infrastructure/` — nothing in here touches storage. It sits at the feature
/// root instead of inside `domain/` because it names localization keys, and
/// `domain/` references nothing outside the feature.
///
/// Seeds carry a translation key, not a translated name: the seed runs once,
/// so a name resolved here would be stuck in the language of first launch.
///
/// The id and its translation key are both spelled out per row instead of
/// building `'category.$id'`. It reads as duplication, but an interpolated key
/// cannot be checked by anything: a category with no translation would ship
/// showing `category.foo` on screen. Naming the [LocaleKeys] constant makes
/// that a compile error instead.
List<Category> defaultCategories() => [
  _seed(
    'food',
    LocaleKeys.category_food,
    CategoryIcon.food,
    0xFFE57373,
  ),
  _seed(
    'transport',
    LocaleKeys.category_transport,
    CategoryIcon.transport,
    0xFF64B5F6,
  ),
  _seed(
    'home',
    LocaleKeys.category_home,
    CategoryIcon.home,
    0xFF81C784,
  ),
  _seed(
    'bills',
    LocaleKeys.category_bills,
    CategoryIcon.bills,
    0xFFFFB74D,
  ),
  _seed(
    'health',
    LocaleKeys.category_health,
    CategoryIcon.health,
    0xFF4DB6AC,
  ),
  _seed(
    'shopping',
    LocaleKeys.category_shopping,
    CategoryIcon.shopping,
    0xFFBA68C8,
  ),
  _seed(
    'entertainment',
    LocaleKeys.category_entertainment,
    CategoryIcon.entertainment,
    0xFF7986CB,
  ),
  _seed(
    'education',
    LocaleKeys.category_education,
    CategoryIcon.education,
    0xFFA1887F,
  ),
  _seed(
    'travel',
    LocaleKeys.category_travel,
    CategoryIcon.travel,
    0xFF4FC3F7,
  ),
  _seed(
    'other',
    LocaleKeys.category_misc,
    CategoryIcon.other,
    0xFF90A4AE,
  ),
  _seed(
    'salary',
    LocaleKeys.category_salary,
    CategoryIcon.salary,
    0xFF66BB6A,
  ),
  _seed(
    'gift',
    LocaleKeys.category_gift,
    CategoryIcon.gift,
    0xFFF06292,
  ),
  _seed(
    'savings',
    LocaleKeys.category_savings,
    CategoryIcon.savings,
    0xFF9CCC65,
  ),
];

Category _seed(String id, String nameKey, CategoryIcon icon, int colorArgb) =>
    Category(id: id, nameKey: nameKey, icon: icon, colorArgb: colorArgb);
