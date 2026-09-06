import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/tempo.dart';

/// What a finished run was worth, kept so the summary can animate from before
/// it to after it.
class RunSummary {
  const RunSummary({
    required this.kazanc,
    required this.musteri,
    required this.xpOnce,
    required this.gunOnce,
    required this.atlananGun,
    required this.zirveTempo,
    this.yanik = 0,
    this.kizgin = 0,
    this.kritik = 0,
    this.enUzunSeri = 0,
    this.hedef = 0,
    this.hedefTamam = false,
  });

  /// What the day is judged on. Counted during the run because none of it
  /// survives the end of one: by the time the summary is built the grill is
  /// empty and everybody has gone home.
  final int yanik;
  final int kizgin;
  final int kritik;
  final int enUzunSeri;

  /// How many happy customers the day asked for, and whether it got them.
  final int hedef;
  final bool hedefTamam;

  /// What the day earned, in the order the summary should read them out.
  List<DayBadge> get rozetler => [
    for (final rozet in DayBadge.values)
      if (rozet.kazanildi(this)) rozet,
  ];

  final int kazanc;

  /// How many customers left with everything they asked for.
  final int musteri;
  final int xpOnce;
  final int gunOnce;

  /// How many levels the run crossed.
  final int atlananGun;

  /// The best the counter read all run.
  final TempoBand zirveTempo;

  bool get seviyeAtladi => atlananGun > 0;
}

/// Something a day can be worth saying out loud.
///
/// Eight, because the summary can show four and a day should not earn all of
/// them: a badge you get every time is a decoration. They are derived from
/// the run rather than awarded during it, so nothing has to be remembered
/// and the summary is the only place that knows they exist.
enum DayBadge {
  /// Nothing burnt, nobody left angry. The one everybody is chasing.
  kusursuz,
  temiz,
  sabirli,
  hedef,
  seri,
  kurtarici,
  ates,
  dolu;

  bool kazanildi(RunSummary run) => switch (this) {
    // The three are exclusive on purpose: a flawless day used to earn all
    // three, which made two of them decoration on the one that mattered.
    kusursuz => run.yanik == 0 && run.kizgin == 0 && run.musteri > 0,
    temiz => run.yanik == 0 && run.kizgin > 0 && run.musteri > 0,
    sabirli => run.kizgin == 0 && run.yanik > 0 && run.musteri > 0,
    hedef => run.hedefTamam,
    seri => run.enUzunSeri >= Balance.rozetSeri,
    kurtarici => run.kritik >= Balance.rozetKritik,
    ates => run.zirveTempo == TempoBand.ates,
    // Half again what the day asked for.
    dolu => run.hedef > 0 && run.musteri >= (run.hedef * 1.5).round(),
  };
}
