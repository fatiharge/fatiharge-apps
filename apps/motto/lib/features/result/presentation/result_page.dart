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
  const ResultPage({required this.result, this.offerCard, super.key});

  final api.ResultResponse result;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerCard());
    unawaited(getIt<Analytics>().record(MottoEvent.resultView));
  }

  static const _readingPause = Duration(milliseconds: 900);

  Future<void> _offerCard() async {
    await Future<void>.delayed(_readingPause);
    if (!mounted) return;

    final offer = widget.offerCard ?? _push;
    await offer(context, widget.result.archetype);
  }

  Future<void> _push(BuildContext context, api.ArchetypeResponse archetype) =>
      context.router.push(ShareCardRoute(archetype: archetype));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final archetype = widget.result.archetype;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          children: [
            Text(
              'SENİN ARKETİPİN',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(archetype.name, style: text.displaySmall),
            const SizedBox(height: 20),
            Container(width: 56, height: 3, color: scheme.primary),
            const SizedBox(height: 20),
            Text(archetype.summary, style: text.bodyLarge),
            const SizedBox(height: 28),
            Text(
              '“${archetype.motto}”',
              style: text.titleLarge?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: () => context.router.push(
                ShareCardRoute(archetype: archetype),
              ),
              icon: const Icon(Icons.ios_share),
              label: const Text('Kartı paylaş'),
            ),
            const SizedBox(height: 12),
            // Offered here because this is the moment the motto means
            // something. A chain proposed on a later screen is a chain
            // proposed to someone who has already put the phone down.
            OutlinedButton(
              onPressed: () => context.router.push(const ShellRoute()),
              child: const Text('Zincirini başlat'),
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
