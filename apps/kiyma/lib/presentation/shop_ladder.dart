import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/palette.dart';

/// One ladder, drawn whole.
///
/// Every rung shows, bought or not and reachable or not. The shop used to
/// list only what money could touch today, which meant a player on day three
/// saw four rows and no reason to believe there was a game past them. A
/// ladder that shows its top is what makes the bottom worth climbing — even,
/// and especially, for somebody who will stop before they reach it.
class Merdiven extends StatelessWidget {
  const Merdiven({
    required this.grup,
    required this.unlocks,
    required this.para,
    required this.onBuy,
    this.genislik = 210,
    super.key,
  });

  final Grup grup;
  final Unlocks unlocks;
  final int para;
  final void Function(Unlock) onBuy;
  final double genislik;

  @override
  Widget build(BuildContext context) {
    final rungs = Unlocks.kademeler(grup);
    final kademe = unlocks.kademe(grup);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'grup.${grup.id}'.tr(),
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: KiymaPalette.komur,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$kademe/${rungs.length}',
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: KiymaPalette.celik,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Text(
              'grup.${grup.id}_ne'.tr(),
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: KiymaPalette.celik,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final unlock in rungs)
                SizedBox(
                  width: genislik,
                  child: KademeKarti(
                    unlock: unlock,
                    alindi: unlock.kademe <= kademe,
                    sirada: unlock.kademe == kademe + 1,
                    affordable: para >= unlock.price,
                    onBuy: () => onBuy(unlock),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One rung: what it is, what it changes, and what it costs.
class KademeKarti extends StatelessWidget {
  const KademeKarti({
    required this.unlock,
    required this.alindi,
    required this.sirada,
    required this.affordable,
    required this.onBuy,
    super.key,
  });

  final Unlock unlock;

  /// Already owned. Kept on screen rather than dropped: a ladder with its
  /// bottom rungs missing does not read as progress.
  final bool alindi;

  /// The next rung. The only one money can reach.
  final bool sirada;

  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: alindi || sirada ? 1 : 0.45,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: alindi
            ? KiymaPalette.krema.withValues(alpha: 0.55)
            : KiymaPalette.krema,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: KiymaPalette.komur.withValues(alpha: sirada ? 0.7 : 0.25),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'kilit.${unlock.id}'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KiymaPalette.komur,
            ),
          ),
          const SizedBox(height: 3),
          // The line that was missing. A name and a price is not information:
          // nobody could tell what "Ocak körüğü" was for.
          Text(
            'kilit.${unlock.id}_ne'.tr(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: KiymaPalette.celik,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: alindi
                ? const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: KiymaPalette.celik,
                    ),
                  )
                : ChunkyButton(
                    // No currency symbol anywhere: the game pays in gold, and
                    // Rubik has no lira glyph, so it came out as a box.
                    label: '${unlock.price}',
                    icon: Icons.paid_rounded,
                    onPressed: sirada && affordable ? onBuy : null,
                  ),
          ),
        ],
      ),
    ),
  );
}
