import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/dev.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/kiyma_game.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/route/app_router.gr.dart';
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
  // Built here and closed with the page, which is what ends the run — the
  // back gesture included.
  late final KiymaCubit _cubit = getIt<KiymaCubit>()..startDay();

  /// Scoped to the page, not to the process. As a static it survived the run
  /// that raised it: a toast fired in the last second of a day was still on
  /// screen when the next one opened, because the timer that would have
  /// cleared it was cancelled with the page.
  final ValueNotifier<String?> _toast = ValueNotifier(null);
  Timer? _toastTimer;

  void _say(DayEvent event) {
    final key = _toastKey(event);
    if (key == null) return;
    _toast.value = key.tr();
    _toastTimer?.cancel();
    _toastTimer = Timer(
      const Duration(milliseconds: 1100),
      () => _toast.value = null,
    );
  }

  /// A phone call must not freeze the counter and hand it back under the
  /// player's finger; it pauses, and they choose when to go on.
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _cubit.duraklat(durdur: true),
      onInactive: () => _cubit.duraklat(durdur: true),
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    _toastTimer?.cancel();
    _toast.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // The back gesture used to end the run outright. It opens the card the
    // player can leave from instead.
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _cubit.duraklat(durdur: true);
    },
    child: BlocProvider.value(
      value: _cubit,
      child: _GameView(toast: _toast, onEvent: _say),
    ),
  );
}

String? _toastKey(DayEvent event) => switch (event) {
  DayEvent.reddedildi => 'olay.reddedildi',
  DayEvent.yandi => 'olay.yandi',
  DayEvent.mangalDolu => 'olay.mangal_dolu',
  DayEvent.altinSupuruldu => 'olay.altin_supuruldu',
  DayEvent.gecersiz => 'olay.gecersiz',
  DayEvent.musteriKizgin => 'olay.musteri_kizgin',
  DayEvent.sonSiparis => 'olay.son_siparis',
  DayEvent.fikirDegisti => 'olay.fikir_degisti',
  DayEvent.bahsis => 'olay.bahsis',
  DayEvent.gunlukHedef => 'olay.gunluk_hedef',
  DayEvent.seri => 'olay.seri',
  _ => null,
};

class _GameView extends StatelessWidget {
  const _GameView({required this.toast, required this.onEvent});

  final ValueNotifier<String?> toast;
  final void Function(DayEvent event) onEvent;

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
          onEvent(event);
        },
        child: BlocBuilder<KiymaCubit, KiymaState>(
          builder: (context, state) {
            final run = cubit.run;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (run != null)
                  _GameHost(
                    run: run,
                    onPause: () => cubit.duraklat(durdur: true),
                    insets: MediaQuery.viewPaddingOf(context),
                  ),
                if (state.duraklatildi)
                  _PauseOverlay(onResume: () => cubit.duraklat(durdur: false)),
                _Toast(message: toast),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Everything is stopped behind this, so it swallows what it covers.
class _PauseOverlay extends StatefulWidget {
  const _PauseOverlay({required this.onResume});

  final VoidCallback onResume;

  @override
  State<_PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<_PauseOverlay> {
  VoidCallback get onResume => widget.onResume;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {},
    child: ColoredBox(
      color: const Color(0xCC0B0908),
      child: Center(
        child: BrandCard(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'duraklat.baslik'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: KiymaPalette.komur,
                ),
              ),
              const SizedBox(height: 18),
              ChunkyButton(
                label: 'duraklat.devam'.tr(),
                icon: Icons.play_arrow_rounded,
                big: true,
                onPressed: onResume,
              ),
              const SizedBox(height: 12),
              ChunkyButton(
                label: 'ozet.menu'.tr(),
                icon: Icons.home_rounded,
                color: KiymaPalette.celik,
                onPressed: () =>
                    unawaited(context.router.replaceAll([const MenuRoute()])),
              ),
              // Debug builds only, and behind the pause card so it is never
              // in a screenshot of the game: playing ten days at normal speed
              // to check the tenth is most of an hour.
              if (Dev.acik) ...[
                const SizedBox(height: 12),
                ChunkyButton(
                  label: 'hiz  ${Dev.hiz.toStringAsFixed(0)}x',
                  icon: Icons.fast_forward_rounded,
                  color: KiymaPalette.komur,
                  onPressed: () => setState(Dev.sonrakiHiz),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// [GameWidget] restarts the engine when handed a new game object, and the
/// parent rebuilds whenever money moves.
class _GameHost extends StatefulWidget {
  const _GameHost({
    required this.run,
    required this.onPause,
    required this.insets,
  });

  final DayRun run;
  final VoidCallback onPause;

  /// Passed in rather than read here: the game rebuilds on a new run, not on
  /// a metrics change, so the value has to arrive from a widget that does.
  final EdgeInsets insets;

  @override
  State<_GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<_GameHost> {
  late KiymaGame _game = _build();

  KiymaGame _build() {
    final world = getIt<GameWorld>();
    return KiymaGame(
      ceviri: (key) => key.tr(),
      scene: world.scene,
      art: world.art,
      halos: world.halos,
      backdrop: world.backdrop,
      run: widget.run,
      onPause: widget.onPause,
      insets: widget.insets,
    );
  }

  @override
  void didUpdateWidget(covariant _GameHost old) {
    super.didUpdateWidget(old);
    if (!identical(old.run, widget.run)) {
      _game = _build();
    } else if (old.insets != widget.insets) {
      _game.insetsChanged(widget.insets);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Flame keeps scheduling frames behind the pause card otherwise, which
    // is a lot of work to do for a picture nobody can see.
    _paused ? _game.pauseEngine() : _game.resumeEngine();
  }

  bool get _paused => widget.run.duraklatildi;

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

/// A one-line note that fades out. The player is mid-drag; anything louder
/// would be worse than nothing.
class _Toast extends StatelessWidget {
  const _Toast({required this.message});

  final ValueNotifier<String?> message;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: message,
    builder: (context, shown, _) => IgnorePointer(
      child: AnimatedOpacity(
        opacity: shown == null ? 0 : 1,
        duration: const Duration(milliseconds: 160),
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: KiymaPalette.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(shown ?? '', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ),
    ),
  );
}
