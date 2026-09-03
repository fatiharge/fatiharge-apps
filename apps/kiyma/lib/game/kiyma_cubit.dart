import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:utility_kit/utility_kit.dart';

/// Which screen the player is on. Upgrades sit between days on purpose: a
/// shop that opens mid-service both breaks the rhythm and would let the
/// player stop the patience bars whenever they liked.
enum GamePhase { gunBasi, oynaniyor, gunSonu, magaza }

/// What the frame around the game shows. Deliberately coarse — patience bars
/// and cooking meters move every frame and are drawn on the canvas, so
/// nothing here changes more than a few times a second.
class KiymaState {
  const KiymaState({
    required this.phase,
    required this.gun,
    required this.para,
    required this.toplamKazanc,
    required this.hedef,
    required this.itibar,
    required this.kalanMusteri,
    required this.gunGecildi,
  });

  final GamePhase phase;
  final int gun;
  final int para;
  final int toplamKazanc;
  final int hedef;
  final int itibar;
  final int kalanMusteri;

  /// Whether the cumulative target is already met. Shown during play too: the
  /// bar is the day's real finish line.
  final bool gunGecildi;

  double get hedefOrani => hedef == 0 ? 1 : (toplamKazanc / hedef).clamp(0, 1);
}

class KiymaCubit extends EffectCubit<KiymaState, DayEvent> {
  KiymaCubit(this.scene) : super(_initial);

  static const _initial = KiymaState(
    phase: GamePhase.gunBasi,
    gun: 1,
    para: 0,
    toplamKazanc: 0,
    hedef: 70,
    itibar: Balance.startingReputation,
    kalanMusteri: 0,
    gunGecildi: false,
  );

  final SceneData scene;
  final Progress progress = Progress();

  DayRun? run;

  /// The phase [_emit] keeps unless it is handed a new one.
  ///
  /// The day's own `onChanged` fires for every coin, including the one right
  /// after the last customer leaves. Without somewhere to remember the phase,
  /// that last call would put the day-end card back into play.
  GamePhase _phase = GamePhase.gunBasi;

  /// Reputation as it stood when the day began. A failed day is replayed from
  /// exactly here (design doc 11.3): everything gained and lost is cancelled,
  /// so a bad run never makes the retry harder.
  int _itibarGunBasi = Balance.startingReputation;

  void startDay() {
    _itibarGunBasi = progress.itibar;
    run = DayRun(
      scene: scene,
      progress: progress,
      onChanged: _emit,
      onEvent: _onEvent,
    );
    _emit(GamePhase.oynaniyor);
  }

  void _onEvent(DayEvent event) {
    emitEffect(event);
    if (event == DayEvent.gunBitti) {
      if (!progress.hedefTutturuldu) progress.itibar = _itibarGunBasi;
      _emit(GamePhase.gunSonu);
    }
  }

  /// From the day-end screen. Passing the target advances the day and opens
  /// the shop; missing it replays the same day with the money kept.
  void continueFromEnd() {
    if (progress.hedefTutturuldu) {
      progress.gun++;
      _emit(GamePhase.magaza);
    } else {
      _emit(GamePhase.gunBasi);
    }
  }

  void closeShop() => _emit(GamePhase.gunBasi);

  void buy(Unlock unlock) {
    if (progress.satinAl(unlock)) _emit(GamePhase.magaza);
  }

  void _emit([GamePhase? phase]) {
    _phase = phase ?? _phase;
    emit(
      KiymaState(
        phase: _phase,
        gun: progress.gun,
        para: progress.para,
        toplamKazanc: progress.toplamKazanc,
        hedef: progress.hedef,
        itibar: progress.itibar,
        kalanMusteri: run?.kalanMusteri ?? 0,
        gunGecildi: progress.hedefTutturuldu,
      ),
    );
  }
}
