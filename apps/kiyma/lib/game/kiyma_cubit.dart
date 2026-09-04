import 'package:injectable/injectable.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/game/world.dart';
import 'package:utility_kit/utility_kit.dart';

/// Coarse on purpose: patience and cooking move every frame and are drawn on
/// the canvas, so nothing here changes more than a few times a second.
class KiymaState {
  const KiymaState({
    required this.gun,
    required this.para,
    required this.toplamKazanc,
    required this.hedef,
    required this.kalanMusteri,
    required this.sonOturum,
    required this.ilerleyebilir,
    required this.gunBitti,
  });

  final int gun;
  final int para;
  final int toplamKazanc;
  final int hedef;

  /// Customers still to come, waiting ones included.
  final int kalanMusteri;

  /// What the last run took, for the card that comes after it.
  final int sonOturum;

  final bool ilerleyebilir;
  final bool gunBitti;

  double get hedefOrani => hedef == 0 ? 1 : (toplamKazanc / hedef).clamp(0, 1);
}

/// A singleton because it outlives every screen: the menu, the day card and
/// the counter are three routes over one game.
@lazySingleton
class KiymaCubit extends EffectCubit<KiymaState, DayEvent> {
  KiymaCubit(this._world) : super(_initial);

  static const _initial = KiymaState(
    gun: 1,
    para: 0,
    toplamKazanc: 0,
    hedef: 70,
    kalanMusteri: 0,
    sonOturum: 0,
    ilerleyebilir: false,
    gunBitti: false,
  );

  final GameWorld _world;
  final Progress progress = Progress();

  DayRun? run;

  int _sonOturum = 0;

  /// The day is a counter, not a gate: every run adds to the same total.
  void startDay() {
    _sonOturum = 0;
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
    if (event == DayEvent.gunBitti) {
      _sonOturum = run?.kazanc ?? 0;
      _emit();
    }
  }

  /// Leaving the counter ends the run rather than suspending it: off screen
  /// the clocks stop, and a run you can step out of is a pause button the
  /// design does not have (10.4). Nothing is lost — money banks as it is
  /// earned.
  void abandonRun() {
    final current = run;
    if (current == null) return;
    if (!current.bitti) _sonOturum = current.kazanc;
    run = null;
    _emit();
  }

  /// The player's own choice, and only once the target is behind them.
  void advanceDay() {
    if (progress.gunuIlerlet()) {
      run = null;
      _sonOturum = 0;
      _emit();
    }
  }

  void buy(Unlock unlock) {
    if (progress.satinAl(unlock)) _emit();
  }

  void _emit() => emit(
    KiymaState(
      gun: progress.gun,
      para: progress.para,
      toplamKazanc: progress.toplamKazanc,
      hedef: progress.hedef,
      kalanMusteri: run?.kalanMusteri ?? 0,
      sonOturum: _sonOturum,
      ilerleyebilir: progress.hedefTutturuldu,
      gunBitti: run?.bitti ?? false,
    ),
  );
}
