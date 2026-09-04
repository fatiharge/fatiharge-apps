import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/ui/palette.dart';

/// The three numbers that decide how the run is going, and never more:
/// what is in the till, how far the cumulative target is, and how many
/// customers are still to come.
class Hud extends StatelessWidget {
  const Hud({required this.state, super.key});

  final KiymaState state;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          _Chip(
            icon: Icons.payments_outlined,
            label: 'hud.para'.tr(args: ['${state.para}']),
            accent: KiymaPalette.kor,
          ),
          const SizedBox(width: 8),
          Expanded(child: _TargetBar(state: state)),
          const SizedBox(width: 8),
          _Chip(
            icon: Icons.groups_outlined,
            label: '${state.kalanMusteri}',
            accent: KiymaPalette.soluk,
          ),
        ],
      ),
    ),
  );
}

class _TargetBar extends StatelessWidget {
  const _TargetBar({required this.state});

  final KiymaState state;

  @override
  Widget build(BuildContext context) => Container(
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: KiymaPalette.panel,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        Text(
          'hud.gun'.tr(args: ['${state.gun}']),
          style: const TextStyle(fontSize: 11, color: KiymaPalette.soluk),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: state.hedefOrani,
              minHeight: 6,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: AlwaysStoppedAnimation(
                state.ilerleyebilir ? KiymaPalette.yesil : KiymaPalette.kor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${state.toplamKazanc}/${state.hedef}',
          style: const TextStyle(fontSize: 11, color: KiymaPalette.soluk),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.accent});

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: KiymaPalette.panel,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        Icon(icon, size: 13, color: accent),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
