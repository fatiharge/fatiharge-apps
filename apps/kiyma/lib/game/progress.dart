import 'dart:math' as math;

import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/unlocks.dart';

/// What survives a day: money, the day reached, and what is open.
///
/// [para] and [toplamKazanc] are separate on purpose. The day target is
/// measured against the cumulative figure, so spending on an upgrade never
/// pushes progress backwards.
class Progress {
  int para = 0;
  int toplamKazanc = 0;
  int gun = 1;

  final Unlocks unlocks = Unlocks();

  int get hedef => Balance.target(gun);

  /// Whether the day can be moved on from. The player decides when to take
  /// it: the day is a counter, not a gate, so a target already met simply
  /// stays met until they use it.
  bool get hedefTutturuldu => toplamKazanc >= hedef;

  bool gunuIlerlet() {
    if (!hedefTutturuldu) return false;
    gun++;
    return true;
  }

  void kazan(int miktar) {
    para += miktar;
    toplamKazanc += miktar;
  }

  /// A burn costs money now and slows the cumulative target as well, which is
  /// the whole of its long-term bite — patience never sees it.
  void cezalandir(int miktar) {
    para = math.max(0, para - miktar);
    toplamKazanc = math.max(0, toplamKazanc - miktar);
  }

  bool satinAl(Unlock unlock) {
    if (para < unlock.price || unlocks.has(unlock.id)) return false;
    para -= unlock.price;
    unlocks.open(unlock.id);
    return true;
  }
}
