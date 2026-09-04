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
  const Hud({required this.state, required this.onPause, super.key});

  final KiymaState state;
  final VoidCallback onPause;

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
          const Spacer(),
          _CounterButton(icon: Icons.pause_rounded, onTap: onPause),
        ],
      ),
    ),
  );
}

/// The counter's own button: dark like the rest of the chrome up here, and
/// chunky like everything on the cream screens.
class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 34,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: KiymaPalette.panel,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Icon(icon, size: 16, color: KiymaPalette.kor),
      ),
    ),
  );
}
