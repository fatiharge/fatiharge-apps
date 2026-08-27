import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:motto/theme/motto_palette.dart';

/// The thing people actually post.
///
/// It does not follow the phone's theme, and that is the one place in this app
/// where the system is ignored on purpose: an exported image is looked at in
/// someone else's feed, not in the app. It has one deliberate look, and dark is
/// the one that survives a story background.
///
/// 9:16, because that is the shape every feed wants. Typography carries the
/// identity — there is no illustration to lean on, and a card that needs one is
/// a card that ships late.
class ShareCard extends StatelessWidget {
  const ShareCard({required this.archetype, super.key});

  static const double aspectRatio = 9 / 16;

  /// What the exported image is scaled to. Wide enough that the name stays
  /// sharp when a feed re-compresses it.
  static const exportWidth = 1080.0;

  final api.ArchetypeResponse archetype;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Everything scales from the card's own width, so the preview and the
          // exported image are the same picture at two sizes rather than two
          // layouts that drifted.
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
    // "Kişilik envanteri", never "test sonucun" — guideline 1.4.1 is about
    // which words were used, and this card is the most screenshotted of them.
    return Text(
      'KİŞİLİK ENVANTERİ',
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
    // The app's name, not a QR code. A QR in a story is a thing nobody scans
    // and everybody notices as an advert.
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
