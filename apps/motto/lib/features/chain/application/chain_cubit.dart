import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/reminder_plan.dart';
import 'package:motto/features/chain/domain/turkish_reminder_copy.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';

/// Starts the chain, marks the days, and keeps the reminders true.
///
/// Every path that changes the chain ends in [_reschedule]: a notification
/// already in the system cannot check anything when it fires.
@injectable
class ChainCubit extends Cubit<ChainState> {
  ChainCubit(this._chains, this._store, this._scheduler, this._analytics)
    : super(const ChainState());

  final ChainRepository _chains;
  final ChainStore _store;
  final ReminderScheduler _scheduler;
  final Analytics _analytics;

  @visibleForTesting
  DateTime Function() now = DateTime.now;

  /// The cache first so the screen has something to draw, then the server.
  Future<void> load() async {
    emit(
      state.copyWith(
        chain: _chains.cached,
        hour: _store.hour,
        permissionAsked: _chains.cached.started,
      ),
    );

    final chain = await _chains.load(now());
    emit(state.copyWith(chain: chain, permissionAsked: chain.started));

    if (chain.started) {
      if (state.isBroken(now())) {
        await _analytics.record(MottoEvent.chainBroken);
      }
      await _reschedule();
    }
  }

  /// The only place the permission is asked for: iOS gives exactly one prompt
  /// and this is the first moment the app has earned it. Saying no does not
  /// stop the chain.
  Future<void> start({required int hour}) async {
    final chain = await _chains.start(now());
    await _store.setHour(hour);

    final allowed = await _scheduler.requestPermission();
    emit(
      state.copyWith(
        chain: chain,
        hour: hour,
        remindersAllowed: allowed,
        permissionAsked: true,
      ),
    );

    await _analytics.record(MottoEvent.chainStart);
    await _analytics.record(
      MottoEvent.notifPermission,
      properties: {'result': allowed ? 'granted' : 'denied'},
    );
    await _reschedule();
  }

  Future<void> markToday() async {
    if (state.markedToday(now())) return;

    final chain = await _chains.mark(now(), now());
    await _store.resetUnopened();
    emit(state.copyWith(chain: chain));

    await _analytics.record(
      MottoEvent.chainDayMarked,
      properties: {'streak': '${chain.streakOn(now())}'},
    );
    await _reschedule();
  }

  /// Starts the next fourteen days under [mottoId].
  ///
  /// The server refuses if the period is not actually done, so the button can
  /// be wrong without the chain being wrong.
  Future<void> beginNextPeriod({String? mottoId}) async {
    try {
      emit(
        state.copyWith(
          chain: await _chains.nextPeriod(now(), mottoId: mottoId),
        ),
      );
    } on Object catch (failure, trace) {
      reported('chain', failure, trace);
      return;
    }
    await _analytics.record(MottoEvent.chainStart);
    await _reschedule();
  }

  Future<void> useFreeze() async {
    if (!state.canFreeze(now())) return;

    try {
      emit(state.copyWith(chain: await _chains.freeze(now())));
    } on Object catch (failure, trace) {
      reported('chain', failure, trace);
      return;
    }
    await _reschedule();
  }

  Future<void> setHour(int hour) async {
    await _store.setHour(hour);
    emit(state.copyWith(hour: hour));
    await _reschedule();
  }

  void unawaitedLoad() => unawaited(load());

  Future<void> _reschedule() async {
    if (!await _scheduler.hasPermission()) {
      await _scheduler.cancelAll();
      emit(state.copyWith(remindersAllowed: false));
      return;
    }

    await _scheduler.schedule(
      ReminderPlan.build(
        chain: state.chain,
        now: now(),
        hour: state.hour,
        copy: turkishReminderCopy,
        unopenedInARow: _store.unopenedInARow,
      ),
    );
  }
}
