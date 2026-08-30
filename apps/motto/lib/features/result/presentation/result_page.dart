import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/result/presentation/widgets/basis_section.dart';
import 'package:motto/features/support/presentation/widgets/rejection_sheet.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:motto/route/app_router.gr.dart';

/// What the test produced, and the way to post it.
@RoutePage()
class ResultPage extends StatefulWidget {
  const ResultPage({
    required this.archetype,
    required this.resultId,
    this.justClaimed = false,
    this.offerCard,
    super.key,
  });

  final api.ArchetypeResponse archetype;
  final int resultId;

  /// True only on the way out of the inventory. An old result opened from the
  /// archive is being read, not celebrated: pushing the share card at somebody
  /// who came to look something up is an interruption.
  final bool justClaimed;

  /// How the card gets offered. Injectable so that the behaviour can be
  /// asserted without a router in the tree — the automatic open is the point of
  /// this screen, not a detail to skip in tests.
  final Future<void> Function(BuildContext context, api.ArchetypeResponse)?
  offerCard;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    // The share screen opens itself. Growth is the only thing this version is
    // measuring, and a screen someone has to go looking for measures nothing —
    // but it opens *after* the result has been read, not instead of it.
    if (widget.justClaimed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offerCard());
    }
    unawaited(getIt<Analytics>().record(MottoEvent.resultView));
  }

  static const _readingPause = Duration(milliseconds: 900);

  Future<void> _offerCard() async {
    await Future<void>.delayed(_readingPause);
    if (!mounted) return;

    final offer = widget.offerCard ?? _push;
    await offer(context, widget.archetype);
  }

  Future<void> _push(BuildContext context, api.ArchetypeResponse archetype) =>
      context.router.push(ShareCardRoute(archetype: archetype));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final archetype = widget.archetype;

    return Scaffold(
      // Every way in sits on top of the shell — the funnel replaces the stack
      // with it on purpose — so there is always somewhere behind and the arrow
      // is never a dead end. An arrow rather than a button that always jumps
      // home: somebody reading an old result came from the archive and wants
      // to be put back in it, not on today.
      appBar: AppBar(title: const Text('Sonucun')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Text(
              'SENİN ARKETİPİN',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(archetype.name, style: text.headlineMedium),
            const SizedBox(height: 12),
            Text(
              archetype.summary,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // The motto is the app. It was set below the summary in the same
            // weight as everything else, which made the one line somebody
            // came for read like a caption.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOTTON',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    archetype.motto,
                    style: text.displaySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.router.push(
                ShareCardRoute(archetype: archetype),
              ),
              icon: const Icon(Icons.ios_share),
              label: const Text('Kartı paylaş'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  context.router.push(ReportRoute(resultId: widget.resultId)),
              child: const Text('Rapor'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.router.push(
                DeepReportRoute(resultId: widget.resultId),
              ),
              // "Analiz" is on the 1.4.1 word table; the screen is the same
              // one either way and the word is what gets a listing rejected.
              child: const Text('Derin rapor'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => showRejectionSheet(context),
                child: const Text('Bana uymadı'),
              ),
            ),
            const SizedBox(height: 24),
            const BasisSection(),
          ],
        ),
      ),
    );
  }
}
