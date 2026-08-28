import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/result/application/card_exporter.dart';
import 'package:motto/features/result/presentation/widgets/share_card.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:share_plus/share_plus.dart';

/// The card, and the one button that matters in this whole app. Opened by
/// itself, because a screen nobody navigates to measures nothing.
@RoutePage()
class ShareCardPage extends StatefulWidget {
  const ShareCardPage({required this.archetype, super.key});

  final api.ArchetypeResponse archetype;

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    final analytics = getIt<Analytics>();
    try {
      final exporter = getIt<CardExporter>();
      final png = await exporter.capture(
        _boundaryKey,
        targetWidth: ShareCard.exportWidth,
      );
      if (png == null) return;

      await analytics.record(MottoEvent.shareSheetOpen);
      final outcome = await exporter.share(
        png,
        archetypeName: widget.archetype.name,
      );

      // Dismissed is not a share. Android answers `unavailable` whenever it
      // cannot see which app was picked, so that counts — and the status rides
      // along so the number can be read with that in mind.
      if (outcome != ShareResultStatus.dismissed) {
        await analytics.record(
          MottoEvent.shareComplete,
          properties: {'status': outcome.name},
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  // The edge sits outside the boundary, so it frames the card
                  // on screen without reaching the exported image. In dark
                  // mode the card and the page are the same black, and the
                  // card stopped reading as an object at all.
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    // Wraps exactly the card, so the export has none of the
                    // screen around it.
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: ShareCard(archetype: widget.archetype),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: const Icon(Icons.ios_share),
                label: Text(_sharing ? 'Hazırlanıyor…' : 'Paylaş'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
