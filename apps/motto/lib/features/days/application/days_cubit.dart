import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/support/application/last_archetype.dart';

enum DaysStatus { loading, ready, failed }

@immutable
class DaysState {
  const DaysState({
    this.status = DaysStatus.loading,
    this.periods = const [],
    this.pack,
    this.archetypeId,
  });

  final DaysStatus status;

  /// Newest run first, and inside each one the days in the order they were
  /// marked — which is the order that says which of the fourteen they were.
  final List<api.ChainPeriod> periods;

  final ContentPack? pack;
  final String? archetypeId;

  bool get empty => periods.every((period) => period.days.isEmpty);

  /// Whether the text of a day can be shown at all. Without a package or an
  /// archetype there is a grid and nothing behind it.
  bool get readable => pack != null && archetypeId != null;
}

/// Every day this device marked, and the words each one came with.
@injectable
class DaysCubit extends Cubit<DaysState> {
  DaysCubit(this._chains, this._content, this._archetype)
    : super(const DaysState());

  final api.ChainResourceApi _chains;
  final ContentRepository _content;
  final LastArchetype _archetype;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    try {
      final history = await _chains.chainHistory();
      final bundle = await _content.current();

      emit(
        DaysState(
          status: DaysStatus.ready,
          // Newest first: somebody opening this screen is looking at what they
          // are doing now, not at what they did a month ago.
          periods: [...?history?.periods.reversed],
          pack: bundle == null ? null : ContentPack.fromJson(bundle),
          archetypeId: _archetype.id,
        ),
      );
    } on Object catch (failure, trace) {
      reported('days', failure, trace);
      emit(const DaysState(status: DaysStatus.failed));
    }
  }
}
