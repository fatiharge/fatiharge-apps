import 'package:card_kit/src/common/card_image.dart';
import 'package:card_kit/src/hero/hero_card_data.dart';
import 'package:flutter/material.dart';

/// The one thing a club wants seen first.
///
/// Takes data and an [onTap]; what tapping *does* is decided elsewhere, from a
/// definition the server sends. That is deliberate — it is what lets the panel
/// render this exact widget as a preview with [onTap] left null, instead of
/// keeping a second copy that slowly stops looking like the real one.
class HeroCard extends StatelessWidget {
  const HeroCard({required this.data, this.onTap, super.key});

  final HeroCardData data;

  /// Null makes the card inert — a preview, or a card with no action.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      label: data.headline,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Fixed ratio rather than the image's own: the card sits in a
              // list whose rhythm should not depend on what was uploaded.
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CardImage(url: data.imageUrl),
              ),
            ),
            const SizedBox(height: 12),
            if (data.eyebrow case final eyebrow? when eyebrow.isNotEmpty) ...[
              Text(
                eyebrow.toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: colors.primary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              data.headline,
              // Two lines, then an ellipsis: a headline that wraps to five
              // pushes everything below it off the first screen.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
