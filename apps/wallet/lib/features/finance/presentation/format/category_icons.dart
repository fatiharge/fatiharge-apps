import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Here so the domain never imports Flutter, and so every icon stays a
/// `const IconData` — a dynamic code point defeats icon tree-shaking.
IconData iconFor(CategoryIcon icon) => switch (icon) {
  CategoryIcon.food => Icons.restaurant_outlined,
  CategoryIcon.transport => Icons.directions_bus_outlined,
  CategoryIcon.home => Icons.home_outlined,
  CategoryIcon.bills => Icons.receipt_long_outlined,
  CategoryIcon.health => Icons.favorite_outline,
  CategoryIcon.shopping => Icons.shopping_bag_outlined,
  CategoryIcon.entertainment => Icons.movie_outlined,
  CategoryIcon.education => Icons.school_outlined,
  CategoryIcon.travel => Icons.flight_takeoff_outlined,
  CategoryIcon.salary => Icons.payments_outlined,
  CategoryIcon.gift => Icons.card_giftcard_outlined,
  CategoryIcon.savings => Icons.savings_outlined,
  CategoryIcon.other => Icons.category_outlined,
};

/// Reuses the seeded names: the enum was named after them. Spelled out per
/// row for the same reason the seeds are.
String iconLabelKey(CategoryIcon icon) => switch (icon) {
  CategoryIcon.food => LocaleKeys.category_food,
  CategoryIcon.transport => LocaleKeys.category_transport,
  CategoryIcon.home => LocaleKeys.category_home,
  CategoryIcon.bills => LocaleKeys.category_bills,
  CategoryIcon.health => LocaleKeys.category_health,
  CategoryIcon.shopping => LocaleKeys.category_shopping,
  CategoryIcon.entertainment => LocaleKeys.category_entertainment,
  CategoryIcon.education => LocaleKeys.category_education,
  CategoryIcon.travel => LocaleKeys.category_travel,
  CategoryIcon.salary => LocaleKeys.category_salary,
  CategoryIcon.gift => LocaleKeys.category_gift,
  CategoryIcon.savings => LocaleKeys.category_savings,
  CategoryIcon.other => LocaleKeys.category_misc,
};
