import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/infrastructure/api/outcome.dart';

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
  // Read through the same classifier the repositories use, so a sheet and a
  // cubit can never disagree about what just happened.
  final (title, body) = _words(troubleFrom(failure));

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
              Text(title, style: text.titleLarge),
              const SizedBox(height: 12),
              Text(
                body,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (retry != null) ...[
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    unawaited(retry());
                  },
                  child: Text('trouble.retry'.tr()),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: Text('common.close'.tr()),
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: Text('common.ok'.tr()),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// One sentence per kind, and nothing technical in any of them. A status code
/// is a fact about our server, not about anything the person can do.
(String, String) _words(Trouble trouble) => switch (trouble) {
  Offline() => (
    'trouble.offlineTitle'.tr(),
    'trouble.offlineBody'.tr(),
  ),
  SessionOver() => (
    'trouble.sessionTitle'.tr(),
    'trouble.sessionBody'.tr(),
  ),
  NotAllowed() => (
    'trouble.deniedTitle'.tr(),
    'trouble.deniedBody'.tr(),
  ),
  // A named refusal reaching here means nobody has written what it leads to
  // yet. The server's own message is written for us, not for whoever is
  // holding the phone — it is in English and it names our machinery.
  Refused() => (
    'trouble.refusedTitle'.tr(),
    'trouble.refusedBody'.tr(),
  ),
  Broken() => (
    'trouble.refusedTitle'.tr(),
    'trouble.brokenBody'.tr(),
  ),
};
