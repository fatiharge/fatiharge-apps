import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/domain/chain.dart';
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

  /// Injected the way the chain cubit does it, so "yesterday" is a fact a
  /// test can set rather than one it has to wait for.
  @visibleForTesting
  DateTime Function() now = DateTime.now;

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

  /// Null when there was no yesterday to keep.
  ///
  /// A chain started today has a yesterday on the calendar and none in the
  /// app, and calling that a missed day accuses somebody of failing before
  /// they began.
  bool? _keptYesterday(Chain chain) {
    final started = chain.startedOn;
    if (started == null) return null;

    final yesterday = dayOf(now()).subtract(const Duration(days: 1));
    if (yesterday.isBefore(dayOf(started))) return null;
    return chain.isMarked(yesterday);
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

    // Assembled the same way, one day on. Naming tomorrow costs nothing and is
    // the only thing on this screen that points forwards.
    final tomorrow = DailyAssembler.assemble(
      pack: pack,
      archetypeId: _archetype.id,
      daysMarked: chain.markedDays.length + 1,
    );

    emit(
      DailyState(
        status: DailyStatus.ready,
        content: content,
        keptYesterday: _keptYesterday(chain),
        tomorrow: tomorrow?.title,
        pool: pack.mottosFor(_archetype.id),
      ),
    );
    await _widget.publish(content, streak: chain.streakOn(now()));
    await _analytics.record(
      MottoEvent.dailyContentView,
      properties: {'day_n': '${content.day}'},
    );
  }
}
