import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/reminder_plan.dart';
import 'package:motto/features/chain/domain/turkish_reminder_copy.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';

/// Starts the chain, marks the days, and keeps the reminders true.
///
/// Every path that changes the chain ends in [_reschedule], because a
/// notification already sitting in the system cannot check anything when it
/// fires — the plan is only ever correct because it is rebuilt.
@injectable
class ChainCubit extends Cubit<ChainState> {
  ChainCubit(this._store, this._scheduler, this._analytics)
    : super(const ChainState());

  final ChainStore _store;
  final ReminderScheduler _scheduler;
  final Analytics _analytics;

  /// Overridable so tests are not at the mercy of the clock.
  @visibleForTesting
  DateTime Function() now = DateTime.now;

  /// Read on every open, which is also when the plan gets rebuilt: a chain
  /// that broke while the app was closed is discovered here.
  Future<void> load() async {
    emit(
      state.copyWith(
        chain: _store.read(),
        hour: _store.hour,
        permissionAsked: _store.read().started,
      ),
    );

    if (state.chain.started) {
      if (state.isBroken(now())) {
        await _analytics.record(MottoEvent.chainBroken);
      }
      await _reschedule();
    }
  }

  /// The only place the notification permission is asked for.
  ///
  /// Asked here rather than at launch because this is the first moment the app
  /// has earned it — and because iOS gives exactly one prompt. Saying no does
  /// not stop the chain.
  Future<void> start({required int hour}) async {
    final chain = _store.read().start(now());
    await _store.write(chain);
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

    final chain = state.chain.mark(now());
    await _store.write(chain);
    // Someone who came back and marked a day is someone the reminders reached.
    await _store.resetUnopened();
    emit(state.copyWith(chain: chain));

    await _analytics.record(
      MottoEvent.chainDayMarked,
      properties: {'streak': '${chain.streakOn(now())}'},
    );
    await _reschedule();
  }

  /// Spends the month's make-up on the one missed day.
  Future<void> useFreeze() async {
    if (!state.canFreeze(now())) return;

    final chain = state.chain.freeze(now());
    await _store.write(chain);
    emit(state.copyWith(chain: chain));
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
