import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';
import 'package:wallet/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Active categories, then archived ones.
class CategoryView extends StatelessWidget {
  const CategoryView({
    required this.active,
    required this.archived,
    required this.onAdd,
    required this.onArchive,
    required this.onRestore,
    super.key,
  });

  final List<Category> active;
  final List<Category> archived;

  final VoidCallback onAdd;
  final ValueChanged<Category> onArchive;
  final ValueChanged<Category> onRestore;

  @override
  Widget build(BuildContext context) {
    if (active.isEmpty && archived.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: context.tr(LocaleKeys.categories_empty_title),
        message: context.tr(LocaleKeys.categories_empty_message),
        action: FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(context.tr(LocaleKeys.categories_add)),
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final category in active)
          _CategoryTile(
            category: category,
            actionIcon: Icons.archive_outlined,
            actionTooltip: context.tr(LocaleKeys.categories_archive),
            onAction: () => onArchive(category),
          ),
        if (archived.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(
              context.tr(LocaleKeys.categories_archived),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              context.tr(LocaleKeys.categories_archived_hint),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final category in archived)
            _CategoryTile(
              category: category,
              dimmed: true,
              actionIcon: Icons.unarchive_outlined,
              actionTooltip: context.tr(LocaleKeys.categories_restore),
              onAction: () => onRestore(category),
            ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
    this.dimmed = false,
  });

  final Category category;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onAction;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorArgb);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: dimmed ? 0.08 : 0.16),
        foregroundColor: dimmed ? Theme.of(context).disabledColor : color,
        child: Icon(iconFor(category.icon), size: 20),
      ),
      title: Text(
        category.displayName(context),
        style: dimmed
            ? TextStyle(color: Theme.of(context).disabledColor)
            : null,
      ),
      trailing: IconButton(
        onPressed: onAction,
        icon: Icon(actionIcon),
        tooltip: actionTooltip,
      ),
    );
  }
}
