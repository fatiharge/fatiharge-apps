import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/kiyma_game.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:utility_kit/utility_kit.dart';

/// The counter and the numbers above it. When the queue empties the day card
/// takes over again.
@RoutePage()
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    final cubit = getIt<KiymaCubit>();
    if (cubit.run == null || cubit.run!.bitti) cubit.startDay();
  }

  @override
  void dispose() {
    // Also covers the back gesture: stepping out ends the run.
    getIt<KiymaCubit>().abandonRun();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: getIt<KiymaCubit>(),
    child: const _GameView(),
  );
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KiymaCubit>();
    return Scaffold(
      backgroundColor: KiymaPalette.zemin,
      body: EffectListener<KiymaCubit, DayEvent>(
        bloc: cubit,
        onEffect: (context, event) {
          if (event == DayEvent.gunBitti) {
            unawaited(context.router.replace(const SummaryRoute()));
            return;
          }
          _Toast.show(context, event);
        },
        child: BlocBuilder<KiymaCubit, KiymaState>(
          builder: (context, state) {
            final run = cubit.run;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (run != null) _GameHost(run: run),
                Align(
                  alignment: Alignment.topCenter,
                  child: Hud(state: state),
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

/// [GameWidget] restarts the engine when handed a new game object, and the
/// parent rebuilds whenever money moves.
class _GameHost extends StatefulWidget {
  const _GameHost({required this.run});

  final DayRun run;

  @override
  State<_GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<_GameHost> {
  late KiymaGame _game = _build();

  KiymaGame _build() {
    final world = getIt<GameWorld>();
    return KiymaGame(scene: world.scene, art: world.art, run: widget.run);
  }

  @override
  void didUpdateWidget(covariant _GameHost old) {
    super.didUpdateWidget(old);
    if (!identical(old.run, widget.run)) _game = _build();
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

/// A one-line note that fades out. The player is mid-drag; anything louder
/// would be worse than nothing.
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
            child: Text(message ?? '', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ),
    ),
  );
}
