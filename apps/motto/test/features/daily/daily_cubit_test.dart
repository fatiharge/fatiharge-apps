import 'dart:convert';
import 'dart:io';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/application/daily_widget.dart';
import 'package:motto/features/daily/domain/daily_content.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockContent extends Mock implements ContentRepository {}

class _MockEvents extends Mock implements api.EventResourceApi {}

class _MockWidget extends Mock implements DailyWidget {}

class _MockChains extends Mock implements ChainRepository {}

class _FakeContent extends Fake implements DailyContent {}

void main() {
  late _MockContent content;
  late _MockWidget widget;
  late SharedPreferences preferences;

  setUpAll(() {
    registerFallbackValue(api.EventBatch());
    registerFallbackValue(_FakeContent());
  });

  Future<DailyCubit> build({
    String? archetype,
    int marked = 0,
    DateTime? today,
  }) async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    final chains = _MockChains();
    when(() => chains.cached).thenReturn(
      Chain(
        startedOn: marked > 0 ? DateTime(2026, 3) : null,
        markedDays: {
          for (var day = 1; day <= marked; day++) DateTime(2026, 3, day),
        },
      ),
    );

    final lastArchetype = LastArchetype(preferences);
    if (archetype != null) await lastArchetype.remember(archetype);

    content = _MockContent();
    when(content.current).thenAnswer(
      (_) async =>
          jsonDecode(
                File('test/fixtures/content_bundle.json').readAsStringSync(),
              )
              as Map<String, dynamic>,
    );

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    widget = _MockWidget();
    when(
      () => widget.publish(any(), streak: any(named: 'streak')),
    ).thenAnswer((_) async {});

    return DailyCubit(
      content,
      lastArchetype,
      chains,
      Analytics(EventQueue(preferences), events),
      widget,
    )..now = () => today ?? DateTime(2026, 3, marked + 1);
  }

  test('without a result there is nothing personal to say', () async {
    final cubit = await build();

    await cubit.load();

    // Saying something general instead would be exactly the horoscope this is
    // trying not to be.
    expect(cubit.state.status, DailyStatus.noResultYet);
    expect(cubit.state.content, isNull);
  });

  test('a fresh chain is on day one', () async {
    final cubit = await build(archetype: 'quiet_builder');

    await cubit.load();

    expect(cubit.state.status, DailyStatus.ready);
    expect(cubit.state.content!.day, 1);
  });

  test('the day follows how many days were marked, not the streak', () async {
    // Losing your place in the content because you missed two days punishes
    // the person who came back.
    final cubit = await build(archetype: 'quiet_builder', marked: 5);

    await cubit.load();

    expect(cubit.state.content!.day, 5);
  });

  test('the day reaches the home screen', () async {
    final cubit = await build(archetype: 'spark', marked: 3);

    await cubit.load();

    // For someone who said no to notifications this is the only daily contact
    // left.
    verify(() => widget.publish(any(), streak: any(named: 'streak'))).called(1);
  });

  test('publishing to a home screen with no widget on it is fine', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final cubit = await build(archetype: 'spark', marked: 2);
    await cubit.load();

    // The real one, not the mock: there may be no widget placed at all, and
    // outside an app there is no platform channel either. Neither may be able
    // to break the screen that triggered this.
    await expectLater(
      const DailyWidget().publish(cubit.state.content!, streak: 2),
      completes,
    );
  });

  group('what is around today', () {
    test('a chain that kept yesterday says so', () async {
      // Three days marked, the first three of March, and today is the fourth.
      final cubit = await build(archetype: 'quiet_builder', marked: 3);
      await cubit.load();

      expect(cubit.state.keptYesterday, isTrue);
    });

    test('a day missed yesterday is not hidden', () async {
      final cubit = await build(
        archetype: 'quiet_builder',
        marked: 3,
        today: DateTime(2026, 3, 6),
      );
      await cubit.load();

      expect(cubit.state.keptYesterday, isFalse);
    });

    test(
      'before the chain starts there is no yesterday to have kept',
      () async {
        final cubit = await build(archetype: 'quiet_builder');
        await cubit.load();

        expect(cubit.state.keptYesterday, isNull);
      },
    );

    // Otherwise the first day opens by telling somebody they already failed.
    test('a chain started today has no yesterday either', () async {
      final cubit = await build(
        archetype: 'quiet_builder',
        marked: 1,
        today: DateTime(2026, 3),
      );
      await cubit.load();

      expect(cubit.state.keptYesterday, isNull);
    });

    // Naming it is the only thing on that screen pointing forwards.
    test('tomorrow is named, and it is not today', () async {
      final cubit = await build(archetype: 'quiet_builder', marked: 3);
      await cubit.load();

      expect(cubit.state.tomorrow, isNotNull);
      expect(cubit.state.tomorrow, isNot(cubit.state.content!.title));
    });
  });

  // Four were written per archetype and only the first was ever reachable;
  // the pool is what a second period picks from.
  test("the archetype's whole motto pool reaches the screen", () async {
    final cubit = await build(archetype: 'quiet_builder', marked: 3);
    await cubit.load();

    expect(cubit.state.pool.length, greaterThan(1));
    expect(
      cubit.state.pool.every((m) => m.archetypeId == 'quiet_builder'),
      isTrue,
    );
    expect(cubit.state.pool.first.motto, cubit.state.content!.mottoLine);
  });

  // The gallery is premium and it is a list of everyone there is, so it needs
  // the whole table — not the archetypes this device happens to have had.
  test('every archetype reaches the app, not only the ones given', () async {
    final cubit = await build(archetype: 'quiet_builder', marked: 1);
    await cubit.load();

    expect(cubit.state.archetypes.length, greaterThan(1));
    expect(
      cubit.state.archetypes.map((a) => a.id),
      contains('quiet_builder'),
    );
  });

  test('and they arrive even before there is a result', () async {
    final cubit = await build();
    await cubit.load();

    expect(cubit.state.status, DailyStatus.noResultYet);
    expect(cubit.state.archetypes, isNotEmpty);
  });

  // The row that opens the result — and through it the paid report — used to
  // come from the server alone, so the door closed whenever the network did.
  test('my own archetype comes from the package, not the server', () async {
    final cubit = await build(archetype: 'quiet_builder', marked: 1);
    await cubit.load();

    expect(cubit.state.mine, isNotNull);
    expect(cubit.state.mine!.id, 'quiet_builder');
    expect(cubit.state.mine!.name, isNotEmpty);
  });

  test('tomorrow is not today, even before the chain starts', () async {
    final cubit = await build(archetype: 'quiet_builder');
    await cubit.load();

    // Nothing marked and one day marked are both day one, so adding one to a
    // count of zero used to give day one again and "yarın" repeated today.
    expect(cubit.state.content!.day, 1);
    expect(cubit.state.tomorrow, isNot(cubit.state.content!.title));
  });
}
