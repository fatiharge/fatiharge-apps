import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.icon,
    required this.filled,
    required this.label,
  });

  final IconData icon;
  final IconData filled;
  final String label;
}

/// A floating bar rather than a full-width one.
///
/// No `BackdropFilter`: the glass look is the usual way to do this and it
/// re-renders the blur every frame — with the mascot animating on top of it,
/// that is a constant cost for a difference nobody can point at. A translucent
/// colour and a shadow read the same and cost nothing.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.index,
    required this.onSelected,
    super.key,
  });

  static const height = 62.0;

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: dark
                ? scheme.surfaceContainerHigh
                : scheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _Item(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.filled : item.icon,
              size: 20,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
            // The label shows only on the selected one: two labels sitting
            // there permanently is what makes a bar look like 2014.
            if (selected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.label,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: text.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
