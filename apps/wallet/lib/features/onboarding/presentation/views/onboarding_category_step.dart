import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';

class OnboardingCategoryStep extends StatelessWidget {
  const OnboardingCategoryStep({
    required this.categories,
    required this.keptIds,
    required this.onToggle,
    super.key,
  });

  final List<Category> categories;
  final Set<String> keptIds;
  final void Function(String id, {required bool keep}) onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final category in categories)
        CheckboxListTile(
          value: keptIds.contains(category.id),
          onChanged: (keep) => onToggle(category.id, keep: keep ?? false),
          secondary: CircleAvatar(
            backgroundColor: Color(category.colorArgb).withValues(alpha: 0.16),
            foregroundColor: Color(category.colorArgb),
            child: Icon(iconFor(category.icon), size: 20),
          ),
          title: Text(category.displayName(context)),
        ),
    ],
  );
}
