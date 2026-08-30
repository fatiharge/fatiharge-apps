import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.gr.dart';

/// Why the game will not open, and what to do about it.
///
/// Two sentences rather than one, because "you have not earned one yet" and
/// "you have used them all" ask for opposite things — the first sends somebody
/// to the day's work, the second tells them to stop for today. A single "no
/// turns left" would send the person who could earn one away empty-handed.
class NoTurnsSheet extends StatelessWidget {
  const NoTurnsSheet._({required this.nothingLeftToEarn});

  /// Whether the day has already paid everything it can — both the mark and
  /// the three things. Either one still outstanding means there is a turn to
  /// go and earn, and telling somebody to come back tomorrow would send them
  /// away from it.
  final bool nothingLeftToEarn;

  static Future<void> show(
    BuildContext context, {
    required bool nothingLeftToEarn,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => NoTurnsSheet._(nothingLeftToEarn: nothingLeftToEarn),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Oyun hakkın bitti', style: text.titleLarge),
            const SizedBox(height: 12),
            Text(
              nothingLeftToEarn
                  ? 'Bugünlük tüm haklarını bitirdin. Yeni hak için yarınki '
                        'görevlerini bekle.'
                  : 'Önce görevini bitir, hakkını kazan.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (nothingLeftToEarn)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tamam'),
              )
            else
              FilledButton(
                onPressed: () {
                  // Read here rather than in `build`: a sheet that asks for
                  // the router before anybody has pressed anything cannot be
                  // shown in a test, and this sheet is mostly words.
                  final router = context.router.root;
                  Navigator.of(context).pop();
                  // The tab rather than a pushed copy: the three things live in
                  // Görevler, and a second list of them is a second list that
                  // can disagree with the first.
                  router.popUntilRoot();
                  router
                      .innerRouterOf<TabsRouter>(ShellRoute.name)
                      ?.setActiveIndex(1);
                },
                child: const Text('Görevlere git'),
              ),
          ],
        ),
      ),
    );
  }
}
