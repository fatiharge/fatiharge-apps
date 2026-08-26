import 'package:flutter/material.dart';

/// A plain [ListTile] rather than [RadioListTile]: the radio API changed shape
/// across recent Flutter versions, and a check mark reads the same while
/// staying on widgets this app already uses everywhere else.
class SettingOptionTile extends StatelessWidget {
  const SettingOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : null),
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: scheme.primary) : null,
      selected: selected,
      onTap: onTap,
    );
  }
}
