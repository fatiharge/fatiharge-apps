import 'package:flutter/material.dart';

/// How far in, without a number.
///
/// "7 / 20" tells someone how much is left to endure. A bar says the same thing
/// without inviting the arithmetic.
class TestProgress extends StatelessWidget {
  const TestProgress({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 250),
      builder: (context, animated, _) => LinearProgressIndicator(
        value: animated,
        minHeight: 3,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
