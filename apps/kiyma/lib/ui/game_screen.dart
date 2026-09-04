import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/kiyma_game.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/panels.dart';
import 'package:utility_kit/utility_kit.dart';

/// The counter, the numbers above it, and whichever between-days card is
/// open. Everything that moves every frame is inside the canvas; everything
/// here rebuilds a handful of times a second at most.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: const _GameView(),
  );
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final world = getIt<GameWorld>();
    final scene = world.scene;
    final assets = world.art;
    final cubit = context.read<KiymaCubit>();
    return Scaffold(
      backgroundColor: KiymaPalette.zemin,
      body: EffectListener<KiymaCubit, DayEvent>(
        bloc: cubit,
        onEffect: _Toast.show,
        child: BlocBuilder<KiymaCubit, KiymaState>(
          builder: (context, state) {
            final run = cubit.run;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (run != null)
                  _GameHost(scene: scene, assets: assets, run: run),
                if (state.phase == GamePhase.oynaniyor)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Hud(state: state),
                  ),
                if (state.phase == GamePhase.gunBasi)
                  DayStartPanel(state: state, onStart: cubit.startDay),
                if (state.phase == GamePhase.gunSonu)
                  DayEndPanel(state: state, onContinue: cubit.continueFromEnd),
                if (state.phase == GamePhase.magaza)
                  ShopPanel(
                    state: state,
                    unlocks: cubit.progress.unlocks,
                    onBuy: cubit.buy,
                    onClose: cubit.closeShop,
                  ),
                const _Toast(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Holds one [KiymaGame] per day.
///
/// [GameWidget] would restart the engine on every rebuild if handed a new
/// game object, and the parent rebuilds whenever money moves.
class _GameHost extends StatefulWidget {
  const _GameHost({
    required this.scene,
    required this.assets,
    required this.run,
  });

  final SceneData scene;
  final GameAssets assets;
  final DayRun run;

  @override
  State<_GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<_GameHost> {
  late KiymaGame _game = _build();

  KiymaGame _build() =>
      KiymaGame(scene: widget.scene, art: widget.assets, run: widget.run);

  @override
  void didUpdateWidget(covariant _GameHost old) {
    super.didUpdateWidget(old);
    if (!identical(old.run, widget.run)) _game = _build();
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

/// A one-line note that fades out. Loud feedback would be worse than none: a
/// refusal already costs patience and the player is mid-drag.
class _Toast extends StatefulWidget {
  const _Toast();

  static final _message = ValueNotifier<String?>(null);
  static Timer? _timer;

  static void show(BuildContext context, DayEvent event) {
    final key = switch (event) {
      DayEvent.reddedildi => 'olay.reddedildi',
      DayEvent.yandi => 'olay.yandi',
      DayEvent.gecersiz => 'olay.gecersiz',
      DayEvent.musteriKizgin => 'olay.musteri_kizgin',
      _ => null,
    };
    if (key == null) return;
    _message.value = key.tr();
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 1100),
      () => _message.value = null,
    );
  }

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> {
  @override
  void dispose() {
    _Toast._timer?.cancel();
    _Toast._timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: _Toast._message,
    builder: (context, message, _) => IgnorePointer(
      child: AnimatedOpacity(
        opacity: message == null ? 0 : 1,
        duration: const Duration(milliseconds: 160),
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: KiymaPalette.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              message ?? '',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    ),
  );
}
