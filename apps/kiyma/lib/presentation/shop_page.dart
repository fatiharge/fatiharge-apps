import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/presentation/render/shop_scene.dart';
import 'package:kiyma/presentation/render/tag_layout.dart';
import 'package:kiyma/presentation/shop_ladder.dart';
import 'package:kiyma/presentation/shop_map.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The shop is the kitchen.
///
/// A list of names and prices could not say what anything was for — "Ocak
/// körüğü, 540" is a word and a number. Standing in the room and hanging a
/// price off the thing itself says it without a sentence: the empty steel
/// well that would hold pickles, the grill that would take a third skewer,
/// the jug that would pour faster. Locked things are drawn here — faint,
/// inside a dashed outline — which is the one place in the game they should
/// be, because seeing what you do not have is the whole point of a shop.
///
/// Eleven rungs have no object to stand on. Those are on [ShopListRoute],
/// reached from here.
@RoutePage()
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: const BrandBackground(child: _Dukkan()),
  );
}

class _Dukkan extends StatefulWidget {
  const _Dukkan();

  @override
  State<_Dukkan> createState() => _DukkanState();
}

class _DukkanState extends State<_Dukkan> {
  /// The object whose card is open.
  ///
  /// Deliberately the only thing on this page that moves. A tag that breathed
  /// would be a repeating animation, and a repeating animation on a page the
  /// flow tests walk through is a `pumpAndSettle` that never returns.
  String? _secili;

  /// One tag per object: the cheapest thing it still sells.
  Map<String, int> _etiketler(Unlocks unlocks) {
    final out = <String, int>{};
    for (final unlock in unlocks.forSale) {
      final bolge = ShopMap.yeri(unlock.id);
      if (bolge == null) continue;
      final varolan = out[bolge];
      if (varolan == null || unlock.price < varolan) out[bolge] = unlock.price;
    }
    return out;
  }

  /// A touch lands on the tag first and the object second.
  ///
  /// The tag is often lifted clear of what it belongs to so two of them do
  /// not print over each other, and an ingredient well is a small target in
  /// its own right. Testing the region alone left tags that could be read
  /// and not pressed.
  void _dokun(Offset point, Unlocks unlocks) {
    final scene = getIt<GameWorld>().scene;
    final vurulan =
        TagLayout.of(scene, _etiketler(unlocks)).at(point) ??
        scene.at(point)?.name;
    // Everything else in the kitchen is scenery here. A touch on the counter
    // opening an empty card would teach the player to stop touching things.
    if (vurulan == null || !ShopMap.bolgeler.contains(vurulan)) return;
    setState(() => _secili = vurulan);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<KiymaCubit, KiymaState>(
    builder: (context, state) {
      final cubit = context.read<KiymaCubit>();
      final unlocks = cubit.progress.unlocks;
      final world = getIt<GameWorld>();
      final scene = world.scene;

      return Stack(
        // Expanded, or the only child that sizes it is the row of buttons in
        // the corner and the room is drawn into fifty pixels.
        fit: StackFit.expand,
        children: [
          // The room, as big as the screen will take it. No title bar: this
          // is the same kitchen the game is played in, and a header would
          // make it a page about the kitchen instead.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) {
                final scale = math.min(
                  box.maxWidth / scene.size.width,
                  box.maxHeight / scene.size.height,
                );
                return Center(
                  child: GestureDetector(
                    onTapUp: (details) =>
                        _dokun(details.localPosition / scale, unlocks),
                    child: CustomPaint(
                      size: Size(
                        scene.size.width * scale,
                        scene.size.height * scale,
                      ),
                      painter: ShopScenePainter(
                        scene: scene,
                        assets: world.art,
                        unlocks: unlocks,
                        etiketler: _etiketler(unlocks),
                        secili: _secili,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Yuvarlak(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.router.maybePop(),
                  ),
                  const Spacer(),
                  SizedBox(
                    // Width only: ChunkyButton fills its row, and a Row hands
                    // its non-flex children unbounded width — but boxing its
                    // height clips the ink it is tapped through.
                    width: 132,
                    child: ChunkyButton(
                      label: 'magaza.gerisi'.tr(),
                      icon: Icons.list_rounded,
                      color: KiymaPalette.celik,
                      onPressed: () =>
                          context.router.push(const ShopListRoute()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BrandChip(
                    icon: Icons.payments_outlined,
                    label: 'hud.para'.tr(args: [goldText(state.para)]),
                  ),
                ],
              ),
            ),
          ),
          if (_secili case final bolge?)
            _Kart(
              bolge: bolge,
              unlocks: unlocks,
              gun: state.gun,
              para: state.para,
              onBuy: cubit.buy,
              onClose: () => setState(() => _secili = null),
            ),
        ],
      );
    },
  );
}

/// A small round button that can sit over the room without being a bar.
class _Yuvarlak extends StatelessWidget {
  const _Yuvarlak({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: KiymaPalette.krema,
    shape: const CircleBorder(
      side: BorderSide(color: KiymaPalette.komur, width: 2),
    ),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(icon, size: 22, color: KiymaPalette.komur),
      ),
    ),
  );
}

/// What one object is selling, one thing at a time.
///
/// A ladder is context, not the offer: the player is standing in front of a
/// grill deciding whether to spend on it, and what they need is what this
/// one purchase does and what it costs. The grill and the jugs sell from two
/// ladders at once, so at most two of these ever stack.
class _Kart extends StatelessWidget {
  const _Kart({
    required this.bolge,
    required this.unlocks,
    required this.gun,
    required this.para,
    required this.onBuy,
    required this.onClose,
  });

  final String bolge;
  final Unlocks unlocks;
  final int gun;
  final int para;
  final void Function(Unlock) onBuy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final satilan = ShopMap.satilan(bolge, unlocks);
    return Positioned.fill(
      // The scrim is a sibling of the card, not its parent. Nesting them put
      // two tap recognisers and a scroll view between the finger and the buy
      // button, and the button stopped being hit at all.
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: const ColoredBox(color: Color(0xCC0B0908)),
            ),
          ),
          // Top-aligned rather than centred: an object that sells two things
          // makes a card taller than a phone held sideways, and a centred
          // scroll view starts it half off the top of the screen.
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: BrandCard(
                width: 460,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final unlock in satilan) ...[
                      ItemCard(
                        unlock: unlock,
                        unlocks: unlocks,
                        gun: gun,
                        affordable: para >= unlock.price,
                        onBuy: () => onBuy(unlock),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (satilan.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'magaza.bitti'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: KiymaPalette.celik,
                          ),
                        ),
                      ),
                    ChunkyButton(
                      label: 'magaza.kapat'.tr(),
                      icon: Icons.close_rounded,
                      color: KiymaPalette.celik,
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
