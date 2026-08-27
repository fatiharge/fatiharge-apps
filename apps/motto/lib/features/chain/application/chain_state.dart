import 'package:meta/meta.dart';
import 'package:motto/features/chain/domain/chain.dart';

@immutable
class ChainState {
  const ChainState({
    this.chain = const Chain(),
    this.hour = 9,
    this.remindersAllowed = true,
    this.permissionAsked = false,
  });

  final Chain chain;
  final int hour;

  /// False once the person has said no. The chain still works — it is the
  /// reminders that stop, and on iOS the answer cannot be asked for twice.
  final bool remindersAllowed;
  final bool permissionAsked;

  int streakToday(DateTime now) => chain.streakOn(now);
  bool markedToday(DateTime now) => chain.isMarked(now);
  bool canFreeze(DateTime now) => chain.canFreezeOn(now);
  bool isBroken(DateTime now) => chain.isBrokenOn(now);

  ChainState copyWith({
    Chain? chain,
    int? hour,
    bool? remindersAllowed,
    bool? permissionAsked,
  }) => ChainState(
    chain: chain ?? this.chain,
    hour: hour ?? this.hour,
    remindersAllowed: remindersAllowed ?? this.remindersAllowed,
    permissionAsked: permissionAsked ?? this.permissionAsked,
  );
}
