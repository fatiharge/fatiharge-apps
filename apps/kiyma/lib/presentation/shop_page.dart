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
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/presentation/render/shop_scene.dart';
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

  @override
  Widget build(BuildContext context) => BlocBuilder<KiymaCubit, KiymaState>(
    builder: (context, state) {
      final cubit = context.read<KiymaCubit>();
      final unlocks = cubit.progress.unlocks;
      final world = getIt<GameWorld>();
      final etiketler = _etiketler(unlocks);

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: KiymaPalette.komur,
                      onPressed: () => context.router.maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'magaza.baslik'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KiymaPalette.komur,
                        ),
                      ),
                    ),
                    SizedBox(
                      // Width as well as height: ChunkyButton fills its row,
                      // so it cannot be laid out where the width is
                      // unbounded — and a Row gives its non-flex children
                      // exactly that.
                      width: 132,
                      height: 36,
                      child: ChunkyButton(
                        label: 'magaza.gerisi'.tr(),
                        icon: Icons.list_rounded,
                        color: KiymaPalette.celik,
                        onPressed: () =>
                            context.router.push(const ShopListRoute()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    BrandChip(
                      icon: Icons.payments_outlined,
                      label: 'hud.para'.tr(args: ['${state.para}']),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final scene = world.scene;
                    final scale = math.min(
                      box.maxWidth / scene.size.width,
                      box.maxHeight / scene.size.height,
                    );
                    return Center(
                      child: GestureDetector(
                        onTapUp: (details) =>
                            _dokun(details.localPosition / scale),
                        child: CustomPaint(
                          size: Size(
                            scene.size.width * scale,
                            scene.size.height * scale,
                          ),
                          painter: ShopScenePainter(
                            scene: scene,
                            assets: world.art,
                            unlocks: unlocks,
                            etiketler: etiketler,
                            secili: _secili,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_secili case final bolge?)
            _Kart(
              bolge: bolge,
              unlocks: unlocks,
              para: state.para,
              onBuy: cubit.buy,
              onClose: () => setState(() => _secili = null),
            ),
        ],
      );
    },
  );

  void _dokun(Offset point) {
    final region = getIt<GameWorld>().scene.at(point);
    // Everything else in the kitchen is scenery here. A touch on the counter
    // opening an empty card would teach the player to stop touching things.
    if (region == null || !ShopMap.bolgeler.contains(region.name)) return;
    setState(() => _secili = region.name);
  }
}

/// What one object sells, as the ladders it carries.
///
/// The grill carries two — the slots across it and the coal in it — and the
/// jugs carry the drink and the jug. Stacking them in one card is what keeps
/// the kitchen from needing two tags on the same object.
class _Kart extends StatelessWidget {
  const _Kart({
    required this.bolge,
    required this.unlocks,
    required this.para,
    required this.onBuy,
    required this.onClose,
  });

  final String bolge;
  final Unlocks unlocks;
  final int para;
  final void Function(Unlock) onBuy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: GestureDetector(
      onTap: onClose,
      child: ColoredBox(
        color: const Color(0xCC0B0908),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: BrandCard(
                width: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final grup in ShopMap.gruplar(bolge))
                      if (unlocks.grupAcik(grup))
                        Merdiven(
                          grup: grup,
                          unlocks: unlocks,
                          para: para,
                          onBuy: onBuy,
                          // Wider than the list's, because there is room
                          // here and a sentence cut in half explains less
                          // than no sentence at all.
                          genislik: 244,
                        ),
                    SizedBox(
                      height: 38,
                      child: ChunkyButton(
                        label: 'magaza.kapat'.tr(),
                        icon: Icons.close_rounded,
                        color: KiymaPalette.celik,
                        onPressed: onClose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
