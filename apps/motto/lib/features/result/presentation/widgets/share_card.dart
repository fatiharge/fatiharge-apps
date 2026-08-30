import 'package:api_client_motto/api.dart' as api;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/theme/motto_palette.dart';

/// The thing people actually post.
///
/// The only place in this app that ignores the phone's theme: an exported
/// image is looked at in someone else's feed, and dark is what survives a
/// story background. 9:16 because that is the shape every feed wants.
class ShareCard extends StatelessWidget {
  const ShareCard({required this.archetype, super.key});

  static const double aspectRatio = 9 / 16;

  /// Wide enough that the name stays sharp when a feed re-compresses it.
  static const exportWidth = 1080.0;

  final api.ArchetypeResponse archetype;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Scaled from the card's own width, so the preview and the export
          // are one picture at two sizes.
          final unit = constraints.maxWidth / 100;

          return ColoredBox(
            color: MottoPalette.darkSurface,
            child: Padding(
              padding: EdgeInsets.all(unit * 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: unit * 4),
                  _Eyebrow(unit: unit),
                  const Spacer(),
                  Text(
                    archetype.name,
                    style: TextStyle(
                      color: MottoPalette.darkInk,
                      fontSize: unit * 13,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -unit * 0.3,
                    ),
                  ),
                  SizedBox(height: unit * 6),
                  Container(
                    width: unit * 14,
                    height: unit * 0.8,
                    color: MottoPalette.seed,
                  ),
                  SizedBox(height: unit * 6),
                  Text(
                    archetype.summary,
                    style: TextStyle(
                      color: MottoPalette.darkInk.withValues(alpha: 0.82),
                      fontSize: unit * 4.6,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '“${archetype.motto}”',
                    style: TextStyle(
                      color: MottoPalette.seed,
                      fontSize: unit * 6,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: unit * 8),
                  _Footer(unit: unit),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    // "Kişilik envanteri", never "test sonucun" — guideline 1.4.1.
    return Text(
      'shareCard.label'.tr(),
      style: TextStyle(
        color: MottoPalette.darkInk.withValues(alpha: 0.45),
        fontSize: unit * 3,
        letterSpacing: unit * 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    // Not a QR: nobody scans one in a story and everybody reads it as an ad.
    return Text(
      'motto',
      style: TextStyle(
        color: MottoPalette.darkInk.withValues(alpha: 0.4),
        fontSize: unit * 3.6,
        fontWeight: FontWeight.w500,
        letterSpacing: unit * 0.1,
      ),
    );
  }
}
