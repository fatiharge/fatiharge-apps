import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/unlocks.dart';

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

  /// Which of the usta's lines have been heard. Kept here rather than on the
  /// screen that shows them so that skipping one survives the run.
  final Set<String> gorulen = {};

  bool gordu(String id) => gorulen.contains(id);

  void gordum(Iterable<String> ids) {
    if (gorulen.containsAll(ids)) return;
    gorulen.addAll(ids);
    _duyur();
  }

  RunSummary? _sonOturum;

  /// The run that just ended. Held here rather than on the cubit because the
  /// summary is a different screen from the counter, and each screen builds
  /// its own.
  RunSummary? get sonOturum => _sonOturum;

  set sonOturum(RunSummary? value) {
    _sonOturum = value;
    _duyur();
  }

  /// Screens that want to know when any of this moved.
  ///
  /// Every screen builds its own cubit over this one object, so a cubit only
  /// ever emitted for what it did itself: buying in the shop left the menu
  /// underneath showing the money it had before, which reads as a purchase
  /// that did not go through. Plain callbacks rather than `ChangeNotifier`
  /// because this file has no Flutter import and the rules must not gain one.
  final List<void Function()> _listeners = [];

  void listen(void Function() onChanged) => _listeners.add(onChanged);

  void unlisten(void Function() onChanged) => _listeners.remove(onChanged);

  void _duyur() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  int get hedef => Balance.target(gun);

  /// XP the current level started at, so a bar can be drawn between levels
  /// rather than from zero.
  int get seviyeTabani => Balance.floor(gun);

  bool get seviyeAtlandi => xp >= hedef;

  /// Levels up as far as the XP reaches, and answers how many days that was.
  int seviyeleriIsle() {
    var gained = 0;
    while (seviyeAtlandi) {
      gun++;
      gained++;
    }
    if (gained > 0) _duyur();
    return gained;
  }

  void kazan(int miktar) {
    para += miktar;
    xp += miktar;
    _duyur();
  }

  /// Debug only: money with no XP behind it, so the level stays whatever was
  /// actually played.
  void bagisla(int miktar) {
    para += miktar;
    _duyur();
  }

  /// A burn costs money now and slows the cumulative target as well, which is
  /// the whole of its long-term bite — patience never sees it.
  void cezalandir(int miktar) {
    para = math.max(0, para - miktar);
    xp = math.max(0, xp - miktar);
    _duyur();
  }

  bool satinAl(Unlock unlock) {
    if (para < unlock.price || unlocks.has(unlock.id)) return false;
    para -= unlock.price;
    unlocks.open(unlock.id);
    _duyur();
    return true;
  }
}
