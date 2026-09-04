import 'package:flutter/material.dart';
import 'package:kiyma/ui/palette.dart';

/// How far through the current day the player is.
///
/// Money is what fills it, but the player is never shown that: they see a
/// level, and the day number turns over when it tops out.
class LevelBar extends StatelessWidget {
  const LevelBar({
    required this.value,
    this.from,
    this.duration = Duration.zero,
    this.onEnd,
    super.key,
  });

  final double value;

  /// Where the fill starts. Set on the summary, where the bar travels from
  /// what the run began with to what it ended with.
  final double? from;

  final Duration duration;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: from ?? value, end: value),
    duration: duration,
    curve: Curves.easeOut,
    onEnd: onEnd,
    builder: (context, shown, _) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: shown,
        minHeight: 12,
        backgroundColor: KiymaPalette.komur.withValues(alpha: 0.12),
        valueColor: const AlwaysStoppedAnimation(KiymaPalette.ates),
      ),
    ),
  );
}
