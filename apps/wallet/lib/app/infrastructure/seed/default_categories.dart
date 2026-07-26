import 'package:wallet/app/features/finance/domain/models/category.dart';

/// The categories a fresh install starts with.
///
/// Names are translated **once, at seed time** and then stored as ordinary
/// data — the user can rename them, and a rename must not be undone by a
/// language switch. [translate] is injected rather than called globally so
/// this stays a pure function.
List<Category> defaultCategories(String Function(String key) translate) => [
  _expense('food', CategoryIcon.food, 0xFFE57373, translate),
  _expense('transport', CategoryIcon.transport, 0xFF64B5F6, translate),
  _expense('home', CategoryIcon.home, 0xFF81C784, translate),
  _expense('bills', CategoryIcon.bills, 0xFFFFB74D, translate),
  _expense('health', CategoryIcon.health, 0xFF4DB6AC, translate),
  _expense('shopping', CategoryIcon.shopping, 0xFFBA68C8, translate),
  _expense('entertainment', CategoryIcon.entertainment, 0xFF7986CB, translate),
  _expense('education', CategoryIcon.education, 0xFFA1887F, translate),
  _expense('travel', CategoryIcon.travel, 0xFF4FC3F7, translate),
  _expense('other', CategoryIcon.other, 0xFF90A4AE, translate),
  _expense('salary', CategoryIcon.salary, 0xFF66BB6A, translate),
  _expense('gift', CategoryIcon.gift, 0xFFF06292, translate),
  _expense('savings', CategoryIcon.savings, 0xFF9CCC65, translate),
];

Category _expense(
  String id,
  CategoryIcon icon,
  int colorArgb,
  String Function(String key) translate,
) => Category(
  id: id,
  name: translate('category.$id'),
  icon: icon,
  colorArgb: colorArgb,
);
