import 'package:kiyma/domain/progress.dart';

/// One short thing the usta says, the first time it becomes true.
///
/// The game explained nothing: a player met a paper roll, a tempo gauge and a
/// pile of gold with no idea that any of them had a rule. A page of tutorial
/// up front is worse — nobody reads it and it delays the first run — so each
/// piece arrives on the day it starts to matter, in two or three lines, and
/// can always be skipped.
class Tanitim {
  const Tanitim(this.id, {this.gun, this.kilit, this.satir = 2});

  /// Names the translation keys: `tanitim.<id>.baslik` and `.1`..`.satir`.
  final String id;

  /// Said on this day or any later one.
  final int? gun;

  /// Said once this unlock has been bought. A thing that is not on the
  /// counter yet is not worth explaining.
  final String? kilit;

  final int satir;

  bool hazir(Progress progress) =>
      (gun == null || progress.gun >= gun!) &&
      (kilit == null || progress.unlocks.opened.contains(kilit));

  static const katalog = [
    Tanitim('hosgeldin', gun: 1, satir: 3),
    Tanitim('tempo', gun: 2),
    Tanitim('altin', gun: 2),
    Tanitim('gidis', gun: 3),
    Tanitim('porsiyon', kilit: 'porsiyon_hatti'),
    Tanitim('icecek', kilit: 'icecek_hatti'),
  ];

  /// Everything true now that has not been said yet, in catalogue order.
  static List<Tanitim> bekleyenler(Progress progress) => [
    for (final tanitim in katalog)
      if (!progress.gordu(tanitim.id) && tanitim.hazir(progress)) tanitim,
  ];
}
