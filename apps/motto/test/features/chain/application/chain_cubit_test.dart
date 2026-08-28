import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockScheduler extends Mock implements ReminderScheduler {}

class _MockChains extends Mock implements ChainRepository {}

class _MockEvents extends Mock implements api.EventResourceApi {}

void main() {
  late _MockScheduler scheduler;
  late _MockChains chains;
  late ChainCubit cubit;

  setUpAll(() {
    registerFallbackValue(api.EventBatch());
    registerFallbackValue(<Reminder>[]);
    registerFallbackValue(DateTime(2026, 3, 3));
  });

  /// Fixed, because a chain is counted in days and a test that runs at 23:59
  /// should not disagree with one that runs at 00:01.
  DateTime at(int day, [int hour = 10]) => DateTime(2026, 3, day, hour);

  Chain chainOf(List<int> days) => Chain(
    startedOn: days.isEmpty ? null : DateTime(2026, 3, days.first),
    markedDays: {for (final day in days) DateTime(2026, 3, day)},
  );

  Future<void> build({bool allowed = true, List<int> marked = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    scheduler = _MockScheduler();
    when(scheduler.requestPermission).thenAnswer((_) async => allowed);
    when(scheduler.hasPermission).thenAnswer((_) async => allowed);
    when(() => scheduler.schedule(any())).thenAnswer((_) async {});
    when(scheduler.cancelAll).thenAnswer((_) async {});

    chains = _MockChains();
    when(() => chains.cached).thenReturn(chainOf(marked));
    when(() => chains.load(any())).thenAnswer((_) async => chainOf(marked));
    when(() => chains.start(any())).thenAnswer((_) async => chainOf([3]));
    when(() => chains.mark(any(), any())).thenAnswer((invocation) async {
      final day = invocation.positionalArguments[0] as DateTime;
      return chainOf(marked).mark(day);
    });
    when(
      () => chains.freeze(any()),
    ).thenAnswer((_) async => chainOf([3, 4, 5]));

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    cubit = ChainCubit(
      chains,
      ChainStore(preferences),
      scheduler,
      Analytics(EventQueue(preferences), events),
    )..now = () => at(3);
  }

  test('starting asks for permission and schedules', () async {
    await build();

    await cubit.start(hour: 8);

    expect(cubit.state.chain.started, isTrue);
    expect(cubit.state.hour, 8);
    verify(scheduler.requestPermission).called(1);
    verify(() => scheduler.schedule(any())).called(1);
  });

  test('saying no stops the reminders, not the chain', () async {
    await build(allowed: false);

    await cubit.start(hour: 8);

    expect(cubit.state.chain.started, isTrue);
    expect(cubit.state.remindersAllowed, isFalse);
    verifyNever(() => scheduler.schedule(any()));
  });

  test('marking goes through the server once, not twice', () async {
    await build(marked: [3]);
    await cubit.load();
    clearInteractions(chains);

    await cubit.markToday();
    await cubit.markToday();

    // The second call is refused locally: the day is already marked.
    verifyNever(() => chains.mark(any(), any()));
  });

  test('a day the server has not seen is marked once', () async {
    await build(marked: [2]);
    cubit.now = () => at(3);
    await cubit.load();

    await cubit.markToday();

    verify(() => chains.mark(any(), any())).called(1);
    expect(cubit.state.streakToday(at(3)), 2);
  });

  test('a chain broken while the app was closed is found on load', () async {
    await build(marked: [1, 2]);
    cubit.now = () => at(9);

    await cubit.load();

    expect(cubit.state.isBroken(at(9)), isTrue);
    expect(cubit.state.streakToday(at(9)), 0);
  });

  test('the cache is shown before the server answers', () async {
    await build(marked: [1, 2, 3]);
    // Never completes: the screen must still have something to draw.
    when(() => chains.load(any())).thenAnswer((_) => Future.any([]));

    unawaited(cubit.load());
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.chain.markedDays, hasLength(3));
  });

  test('a make-up the server refuses leaves the state alone', () async {
    await build(marked: [1, 2]);
    cubit.now = () => at(4);
    await cubit.load();
    when(() => chains.freeze(any())).thenThrow(Exception('offline'));

    await cubit.useFreeze();

    expect(cubit.state.streakToday(at(4)), 0);
  });
}
