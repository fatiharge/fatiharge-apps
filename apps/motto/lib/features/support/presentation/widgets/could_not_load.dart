import 'package:flutter/material.dart';

/// A screen, or a part of one, that could not read what it needed.
///
/// Six copies of this had grown, and the sixth is how I noticed. What they
/// share is not how they look — half sit in a page's flow and half take the
/// whole screen — but what they promise: the sentence says what is missing,
/// and pressing the button asks for exactly the same thing again.
///
/// The words are the caller's, because only the caller knows what did not
/// arrive. The promise is here.
class CouldNotLoad extends StatelessWidget {
  /// Takes the screen. For a page with nothing else on it.
  const CouldNotLoad({required this.said, required this.retry, super.key})
    : _inline = false;

  /// Sits where the missing thing would have been, in a page that still has
  /// other things worth reading. Losing the chain because the task list failed
  /// took a working chain off the screen once.
  const CouldNotLoad.inline({
    required this.said,
    required this.retry,
    super.key,
  }) : _inline = true;

  final String said;

  /// Null when there is nothing to press — a failure somebody cannot ask
  /// again about. Rare, and it should look rare.
  final VoidCallback? retry;

  final bool _inline;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _inline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          said,
          textAlign: _inline ? TextAlign.start : TextAlign.center,
          style: text.bodyLarge,
        ),
        if (retry != null) ...[
          const SizedBox(height: 16),
          // Outlined inline, filled when it is the only thing on the screen:
          // the same promise, weighted for what else is competing with it.
          if (_inline)
            OutlinedButton(onPressed: retry, child: const Text('Tekrar dene'))
          else
            FilledButton(onPressed: retry, child: const Text('Tekrar dene')),
        ],
      ],
    );

    return _inline
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: body,
          )
        : Center(
            child: Padding(padding: const EdgeInsets.all(32), child: body),
          );
  }
}
