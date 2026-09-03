import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/ui/palette.dart';

/// The dimmed card the game pauses behind, between days.
class Panel extends StatelessWidget {
  const Panel({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xCC0B0908),
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: KiymaPalette.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

class DayStartPanel extends StatelessWidget {
  const DayStartPanel({required this.state, required this.onStart, super.key});

  final KiymaState state;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Panel(
    title: 'gun_basi.baslik'.tr(args: ['${state.gun}']),
    children: [
      _Line('gun_basi.hedef'.tr(args: ['${state.hedef}'])),
      _Line('gun_basi.durum'.tr(args: ['${state.toplamKazanc}'])),
      const SizedBox(height: 18),
      FilledButton(onPressed: onStart, child: Text('gun_basi.basla'.tr())),
    ],
  );
}

class DayEndPanel extends StatelessWidget {
  const DayEndPanel({required this.state, required this.onContinue, super.key});

  final KiymaState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Panel(
    title: (state.gunGecildi ? 'gun_sonu.gecti' : 'gun_sonu.kaldi').tr(),
    children: [
      _Line(
        'gun_sonu.kazanc'.tr(args: ['${state.toplamKazanc}', '${state.hedef}']),
      ),
      _Line('gun_sonu.itibar'.tr(args: ['${state.itibar}'])),
      if (!state.gunGecildi) ...[
        const SizedBox(height: 6),
        _Line('gun_sonu.tekrar'.tr()),
      ],
      const SizedBox(height: 18),
      FilledButton(onPressed: onContinue, child: Text('gun_sonu.devam'.tr())),
    ],
  );
}

/// Design doc 10.4: the shop opens between days only. Mid-service it would
/// both break the rhythm and stop the patience bars on demand.
class ShopPanel extends StatelessWidget {
  const ShopPanel({
    required this.state,
    required this.unlocks,
    required this.onBuy,
    required this.onClose,
    super.key,
  });

  final KiymaState state;
  final Unlocks unlocks;
  final void Function(Unlock unlock) onBuy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final forSale = unlocks.forSale.toList();
    return Panel(
      title: 'magaza.baslik'.tr(),
      children: [
        _Line('magaza.bakiye'.tr(args: ['${state.para}'])),
        const SizedBox(height: 10),
        if (forSale.isEmpty)
          _Line('magaza.bos'.tr())
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: forSale.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final unlock = forSale[index];
                final afford = state.para >= unlock.price;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'kilit.${unlock.id}'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: afford
                              ? KiymaPalette.yazi
                              : KiymaPalette.soluk,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: afford ? () => onBuy(unlock) : null,
                      child: Text('₺${unlock.price}'),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 14),
        FilledButton(onPressed: onClose, child: Text('magaza.kapat'.tr())),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: KiymaPalette.soluk),
    ),
  );
}
