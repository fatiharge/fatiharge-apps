import 'package:flutter/material.dart';

/// The image a card draws, and what it draws instead when there is none.
///
/// Every card needs the same three answers — no url, still loading, failed to
/// load — and answering them per card is how three cards end up with three
/// different empty states.
class CardImage extends StatelessWidget {
  const CardImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.icon = Icons.image_outlined,
    super.key,
  });

  final String? url;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.isEmpty) return _Placeholder(icon: icon);

    return Image.network(
      source,
      fit: fit,
      // A card that reflows when its image arrives makes the whole screen jump.
      // The placeholder occupies the same box the image will.
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _Placeholder(icon: icon),
      errorBuilder: (context, _, _) => _Placeholder(icon: icon),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          icon,
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
