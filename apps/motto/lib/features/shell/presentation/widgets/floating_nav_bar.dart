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

/// A floating bar rather than a full-width one, and icons only.
///
/// No labels: three words sitting under three icons is what dates a bar, and
/// the three places here are ordinary enough that an icon carries them. The
/// selected one is said with colour and a dot instead.
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

  static const height = 58.0;

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

    return Semantics(
      // The label is gone from the screen, not from the app: a bar of bare
      // icons is unreadable to a screen reader unless it is said here.
      label: item.label,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              scale: selected ? 1.08 : 1,
              child: Icon(
                selected ? item.filled : item.icon,
                size: 23,
                color: selected
                    ? scheme.primary
                    : scheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 5),
            // A dot rather than a filled pill behind the icon. The pill puts a
            // block of colour in a bar whose whole job is to stay out of the
            // way; four pixels say the same thing and leave the icon as the
            // only shape being read.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: selected ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
