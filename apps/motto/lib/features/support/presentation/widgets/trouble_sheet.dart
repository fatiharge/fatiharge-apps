import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';

/// What to say when something somebody pressed did not happen.
///
/// A sheet rather than a line somewhere on the screen: this is the answer to a
/// question they asked by pressing, and an answer they have to go looking for
/// is not one. Screens that fail to *load* keep their own retry instead — a
/// sheet there closes onto the same empty screen it was explaining.
///
/// Nothing technical reaches this text. A status code is a fact about our
/// server, not about anything the person holding the phone can do.
Future<void> showTroubleSheet(
  BuildContext context, {
  required Object failure,
  Future<void> Function()? retry,
}) {
  // Anything the server answered is a fault on our side; anything that never
  // reached it is a connection. The person can act on the second one, which is
  // the only reason the two sentences differ.
  final reachedUs = failure is api.ApiException;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final text = Theme.of(sheet).textTheme;
      final scheme = Theme.of(sheet).colorScheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                reachedUs ? 'Olmadı' : 'Bağlanamadım',
                style: text.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                reachedUs
                    ? 'Bizim tarafımızda bir aksaklık oldu. Birazdan tekrar '
                          'dene.'
                    : 'İnternet bağlantını kontrol edip tekrar dene.',
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (retry != null) ...[
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    unawaited(retry());
                  },
                  child: const Text('Tekrar dene'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: const Text('Kapat'),
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: const Text('Tamam'),
                ),
            ],
          ),
        ),
      );
    },
  );
}
