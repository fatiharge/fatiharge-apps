import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Maps the domain's [CategoryIcon] onto concrete Material icons.
///
/// The mapping lives here so the domain never imports Flutter, and so every
/// icon stays a `const IconData` (a dynamic code point would defeat icon
/// tree-shaking and bloat the release build).
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

/// What to call an icon out loud.
///
/// Reuses the seeded category names rather than inventing a second set: the
/// enum was named after them, so "Yemek" is already the right word for the
/// fork-and-knife. Spelled out per row for the same reason the seeds are —
/// an interpolated key cannot be checked by anything.
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
