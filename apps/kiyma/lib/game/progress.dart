import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/run_summary.dart';
import 'package:kiyma/game/unlocks.dart';

/// What survives a run: money, the level reached, and what is open.
///
/// [para] is spent; [xp] is not. Levelling is measured against the figure
/// nothing subtracts from, so buying an upgrade never costs progress — which
/// is also why the player is shown a level bar and not a bank balance.
@lazySingleton
class Progress {
  int para = 0;
  int xp = 0;
  int gun = 1;

  final Unlocks unlocks = Unlocks();

  /// The run that just ended. Held here rather than on the cubit because the
  /// summary is a different screen from the counter, and each screen builds
  /// its own.
  RunSummary? sonOturum;

  int get hedef => Balance.target(gun);

  /// XP the current level started at, so a bar can be drawn between levels
  /// rather than from zero.
  int get seviyeTabani => gun <= 1 ? 0 : Balance.target(gun - 1);

  double get seviyeOrani {
    final span = hedef - seviyeTabani;
    return span <= 0 ? 1 : ((xp - seviyeTabani) / span).clamp(0, 1);
  }

  bool get seviyeAtlandi => xp >= hedef;

  /// Levels up as far as the XP reaches, and answers how many days that was.
  int seviyeleriIsle() {
    var gained = 0;
    while (seviyeAtlandi) {
      gun++;
      gained++;
    }
    return gained;
  }

  void kazan(int miktar) {
    para += miktar;
    xp += miktar;
  }

  /// A burn costs money now and slows the cumulative target as well, which is
  /// the whole of its long-term bite — patience never sees it.
  void cezalandir(int miktar) {
    para = math.max(0, para - miktar);
    xp = math.max(0, xp - miktar);
  }

  bool satinAl(Unlock unlock) {
    if (para < unlock.price || unlocks.has(unlock.id)) return false;
    para -= unlock.price;
    unlocks.open(unlock.id);
    return true;
  }
}
