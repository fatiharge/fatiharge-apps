import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';

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
