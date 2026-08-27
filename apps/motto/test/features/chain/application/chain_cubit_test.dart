import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockScheduler extends Mock implements ReminderScheduler {}

class _MockEvents extends Mock implements api.EventResourceApi {}

void main() {
  late SharedPreferences preferences;
  late ChainStore store;
  late _MockScheduler scheduler;
  late ChainCubit cubit;

  setUpAll(() {
    registerFallbackValue(api.EventBatch());
    registerFallbackValue(<Reminder>[]);
  });

  /// Fixed, because a chain is counted in days and a test that runs at 23:59
  /// should not disagree with one that runs at 00:01.
  DateTime at(int day, [int hour = 10]) => DateTime(2026, 3, day, hour);

  Future<void> build({bool allowed = true}) async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    store = ChainStore(preferences);

    scheduler = _MockScheduler();
    when(scheduler.requestPermission).thenAnswer((_) async => allowed);
    when(scheduler.hasPermission).thenAnswer((_) async => allowed);
    when(() => scheduler.schedule(any())).thenAnswer((_) async {});
    when(scheduler.cancelAll).thenAnswer((_) async {});

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    cubit = ChainCubit(
      store,
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

    // iOS gives one prompt and that was it. The chain still works.
    expect(cubit.state.chain.started, isTrue);
    expect(cubit.state.remindersAllowed, isFalse);
    verify(scheduler.cancelAll).called(greaterThan(0));
    verifyNever(() => scheduler.schedule(any()));
  });

  test('marking a day reschedules, and marking it twice does not', () async {
    await build();
    await cubit.start(hour: 8);
    clearInteractions(scheduler);

    cubit.now = () => at(4);
    await cubit.markToday();
    await cubit.markToday();

    expect(cubit.state.streakToday(at(4)), 2);
    verify(() => scheduler.schedule(any())).called(1);
  });

  test('the make-up covers the missed day', () async {
    await build();
    await cubit.start(hour: 8);

    cubit.now = () => at(5);
    expect(cubit.state.canFreeze(at(5)), isTrue);
    await cubit.useFreeze();

    expect(cubit.state.streakToday(at(5)), 2);
    expect(cubit.state.canFreeze(at(5)), isFalse);
  });

  test('a chain broken while the app was closed is found on load', () async {
    await build();
    await cubit.start(hour: 8);

    cubit.now = () => at(9);
    await cubit.load();

    expect(cubit.state.isBroken(at(9)), isTrue);
    expect(cubit.state.streakToday(at(9)), 0);
  });

  test('the chosen hour survives a reload', () async {
    await build();
    await cubit.start(hour: 21);
    await cubit.load();

    expect(cubit.state.hour, 21);
  });
}
