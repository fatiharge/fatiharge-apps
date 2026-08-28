import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/application/daily_widget.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_assembler.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';

/// Assembled here rather than on the server, so a plane or a dead cell is not
/// a reason to show nothing — which is the whole reason the package is
/// downloaded whole rather than a day at a time.
@injectable
class DailyCubit extends Cubit<DailyState> {
  DailyCubit(
    this._content,
    this._archetype,
    this._chain,
    this._analytics,
    this._widget,
  ) : super(const DailyState());

  final ContentRepository _content;
  final LastArchetype _archetype;
  final ChainRepository _chain;
  final Analytics _analytics;
  final DailyWidget _widget;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    // Wrapped because the failure of an unawaited load is otherwise invisible:
    // the state stays `loading` and the screen spins for ever, which reads as a
    // slow network rather than as something broken.
    try {
      await _load();
    } on Object {
      emit(const DailyState(status: DailyStatus.failed));
    }
  }

  Future<void> _load() async {
    final json = await _content.current();
    if (json == null) {
      emit(const DailyState(status: DailyStatus.noContent));
      return;
    }

    final pack = ContentPack.fromJson(json);
    final chain = _chain.cached;

    // Total days marked, not the current streak: losing your place in the
    // content because you missed two days punishes the person who came back.
    final content = DailyAssembler.assemble(
      pack: pack,
      archetypeId: _archetype.id,
      daysMarked: chain.markedDays.length,
    );

    if (content == null) {
      emit(const DailyState(status: DailyStatus.noResultYet));
      return;
    }

    emit(DailyState(status: DailyStatus.ready, content: content));
    await _widget.publish(content, streak: chain.streakOn(DateTime.now()));
    await _analytics.record(
      MottoEvent.dailyContentView,
      properties: {'day_n': '${content.day}'},
    );
  }
}
