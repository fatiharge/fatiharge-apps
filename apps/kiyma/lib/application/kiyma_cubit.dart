import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tutor.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/progress_store.dart';
import 'package:kiyma/infrastructure/world.dart';
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
    required this.duraklatildi,
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

  final bool duraklatildi;

  double get seviyeOrani => Balance.ratio(xp, gun);
}

/// One per screen. What outlives a screen is [Progress]; a run does not —
/// leaving the counter ends it, so the run belongs to the page that shows it
/// and dies with the cubit that page built.
@injectable
class KiymaCubit extends EffectCubit<KiymaState, DayEvent> {
  KiymaCubit(this._world, this.progress, this._store) : super(_initial) {
    progress
      ..listen(_emit)
      ..listen(_write);
    _emit();
  }

  final ProgressStore _store;

  void _dersVeEmit() {
    _dersiIsaretle();
    _emit();
  }

  /// Written on every change rather than at chosen moments: `Progress`
  /// already announces them, and a game that is killed mid-run should lose
  /// the run, never the shop.
  void _write() => unawaited(_store.save(progress));

  static const _initial = KiymaState(
    gun: 1,
    para: 0,
    xp: 0,
    seviyeTabani: 0,
    hedef: 70,
    oturum: null,
    gunBitti: false,
    duraklatildi: false,
  );

  final GameWorld _world;
  final Progress progress;

  DayRun? run;

  void startDay() {
    progress.sonOturum = null;
    // A written lesson first; otherwise the usta reads out whatever was
    // bought since he last spoke.
    final ders = Lesson.bekleyen(progress) ?? Lesson.alimlar(progress);
    run = DayRun(
      scene: _world.scene,
      progress: progress,
      onChanged: _dersVeEmit,
      onEvent: _onEvent,
      ogretmen: ders == null ? null : Tutor(ders),
    );
    _emit();
  }

  /// A lesson counts as heard the moment it ends, however it ended.
  void _dersiIsaretle() {
    final ogretmen = run?.ogretmen;
    if (ogretmen == null || !ogretmen.bitti) return;
    progress.gordum(ogretmen.ders.gorulenler);
  }

  void _onEvent(DayEvent event) {
    emitEffect(event);
    if (event == DayEvent.gunBitti) _bank(emitAfter: true);
  }

  void duraklat({required bool durdur}) {
    final current = run;
    if (current == null) return;
    current.duraklatildi = durdur;
    _emit();
  }

  /// Debug only: enough money to reach the far end of the shop without
  /// playing twenty runs to get there. XP is untouched, so the level is
  /// still whatever was actually played.
  void bagisla(int miktar) => progress.bagisla(miktar);

  void buy(Unlock unlock) => progress.satinAl(unlock);

  /// Closing the page closes the run with it. Nothing is lost: money banks as
  /// it is earned, and what the run was worth is recorded on [Progress].
  @override
  Future<void> close() async {
    progress
      ..unlisten(_emit)
      ..unlisten(_write);
    _bank(emitAfter: false);
    return super.close();
  }

  /// Banks the run and levels up as far as its XP reaches. Money is what
  /// feeds XP, but the two are only ever shown apart.
  void _bank({required bool emitAfter}) {
    final current = run;
    if (current == null) return;

    // Levelling first and on its own line: inside the constructor call a
    // listener would see a Progress that had already turned the day over but
    // not yet recorded what did it.
    final kazanc = current.kazanc;
    final xpOnce = progress.xp - kazanc;
    final gunOnce = progress.gun;
    final atlanan = progress.seviyeleriIsle();
    run = null;
    progress.sonOturum = RunSummary(
      kazanc: kazanc,
      musteri: current.memnunMusteri,
      xpOnce: xpOnce,
      gunOnce: gunOnce,
      atlananGun: atlanan,
      zirveTempo: current.tempo.zirve,
      yanik: current.yanikSayisi,
      kizgin: current.kizginSayisi,
      kritik: current.kritikServis,
      enUzunSeri: current.tempo.enUzunSeri,
      hedef: current.gunlukHedef,
      hedefTamam: current.hedefTamam,
    );
    if (emitAfter) _emit();
  }

  void _emit() => emit(
    KiymaState(
      gun: progress.gun,
      para: progress.para,
      xp: progress.xp,
      seviyeTabani: progress.seviyeTabani,
      hedef: progress.hedef,
      oturum: progress.sonOturum,
      gunBitti: run == null && progress.sonOturum != null,
      duraklatildi: run?.duraklatildi ?? false,
    ),
  );
}
