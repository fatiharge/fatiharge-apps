import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/ui/palette.dart';

/// What is in the till, and nothing else.
///
/// The level and the day belong to the screens between runs; on the counter
/// they are a number nobody can act on. The clock is drawn on the canvas with
/// the other things that move every frame.
class Hud extends StatelessWidget {
  const Hud({required this.state, super.key});

  final KiymaState state;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: KiymaPalette.panel,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 13,
                  color: KiymaPalette.kor,
                ),
                const SizedBox(width: 5),
                Text(
                  'hud.para'.tr(args: ['${state.para}']),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
