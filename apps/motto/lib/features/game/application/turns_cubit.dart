import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/features/game/application/turns_repository.dart';

enum TurnsStatus { loading, ready, failed }

@immutable
class TurnsState {
  const TurnsState({this.status = TurnsStatus.loading, this.remaining = 0});

  final TurnsStatus status;
  final int remaining;

  /// Only when the answer is known and positive.
  ///
  /// An unknown count hides the way in rather than offering one that cannot
  /// work: a card that answers a tap with "there is none" is worse than a card
  /// that was not there. The mascot still offers the game, and that path says
  /// why on its own.
  bool get any => status == TurnsStatus.ready && remaining > 0;
}

/// How many turns today has paid for, kept where the screens can read it.
@injectable
class TurnsCubit extends Cubit<TurnsState> {
  TurnsCubit(this._turns) : super(const TurnsState());

  final TurnsRepository _turns;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    try {
      final credits = await _turns.today();
      emit(
        TurnsState(
          status: TurnsStatus.ready,
          remaining: credits?.remaining ?? 0,
        ),
      );
    } on Object catch (failure, trace) {
      reported('turns', failure, trace);
      emit(const TurnsState(status: TurnsStatus.failed));
    }
  }
}
