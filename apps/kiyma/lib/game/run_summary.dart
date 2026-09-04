/// What a finished run was worth, kept so the summary can animate from before
/// it to after it.
class RunSummary {
  const RunSummary({
    required this.kazanc,
    required this.musteri,
    required this.xpOnce,
    required this.gunOnce,
    required this.atlananGun,
  });

  final int kazanc;

  /// How many customers left with everything they asked for.
  final int musteri;
  final int xpOnce;
  final int gunOnce;

  /// How many levels the run crossed.
  final int atlananGun;

  bool get seviyeAtladi => atlananGun > 0;
}
