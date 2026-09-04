import 'package:injectable/injectable.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/game/world.dart';
import 'package:utility_kit/utility_kit.dart';

/// Coarse on purpose: the clock and the patience bars move every frame and
/// are drawn on the canvas, so nothing here changes more than a few times a
/// second.
class KiymaState {
  const KiymaState({
    required this.gun,
    required this.para,
    required this.xp,
    required this.seviyeTabani,
    required this.hedef,
    required this.oturum,
    required this.gunBitti,
  });

  final int gun;
  final int para;
  final int xp;

  /// Where the current level started and where it ends, so a bar can be drawn
  /// between the two rather than from zero.
  final int seviyeTabani;
  final int hedef;

  /// The run that just ended, or null while one is in progress.
  final RunSummary? oturum;

  final bool gunBitti;

  double get seviyeOrani {
    final span = hedef - seviyeTabani;
    return span <= 0 ? 1 : ((xp - seviyeTabani) / span).clamp(0, 1);
  }
}

/// What a finished run is worth, held so the summary can animate from before
/// it to after it.
class RunSummary {
  const RunSummary({
    required this.kazanc,
    required this.xpOnce,
    required this.gunOnce,
    required this.atlananGun,
  });

  final int kazanc;
  final int xpOnce;
  final int gunOnce;

  /// How many levels the run crossed.
  final int atlananGun;

  bool get seviyeAtladi => atlananGun > 0;
}

/// A singleton because it outlives every screen: the menu, the start card,
/// the counter and the summary are four routes over one game.
@lazySingleton
class KiymaCubit extends EffectCubit<KiymaState, DayEvent> {
  KiymaCubit(this._world) : super(_initial);

  static const _initial = KiymaState(
    gun: 1,
    para: 0,
    xp: 0,
    seviyeTabani: 0,
    hedef: 70,
    oturum: null,
    gunBitti: false,
  );

  final GameWorld _world;
  final Progress progress = Progress();

  DayRun? run;
  RunSummary? _oturum;

  void startDay() {
    _oturum = null;
    run = DayRun(
      scene: _world.scene,
      progress: progress,
      onChanged: _emit,
      onEvent: _onEvent,
    );
    _emit();
  }

  void _onEvent(DayEvent event) {
    emitEffect(event);
    if (event == DayEvent.gunBitti) _close();
  }

  /// Leaving the counter ends the run rather than suspending it: off screen
  /// the clocks stop, and a run you can step out of is a pause the design
  /// does not have (10.4).
  void abandonRun() {
    if (run != null) _close();
  }

  /// Banks the run and levels up as far as its XP reaches. Money is what
  /// feeds XP, but the two are only ever shown apart.
  void _close() {
    final current = run;
    if (current == null) return;

    final xpOnce = progress.xp - current.kazanc;
    final gunOnce = progress.gun;
    _oturum = RunSummary(
      kazanc: current.kazanc,
      xpOnce: xpOnce,
      gunOnce: gunOnce,
      atlananGun: progress.seviyeleriIsle(),
    );
    run = null;
    _emit();
  }

  void buy(Unlock unlock) {
    if (progress.satinAl(unlock)) _emit();
  }

  void _emit() => emit(
    KiymaState(
      gun: progress.gun,
      para: progress.para,
      xp: progress.xp,
      seviyeTabani: progress.seviyeTabani,
      hedef: progress.hedef,
      oturum: _oturum,
      gunBitti: run == null && _oturum != null,
    ),
  );
}
