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

  Future<DailyCubit> build({String? archetype, int marked = 0}) async {
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
          jsonDecode(File('test/fixtures/content_bundle.json').readAsStringSync())
              as Map<String, dynamic>,
    );

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    widget = _MockWidget();
    when(() => widget.publish(any(), streak: any(named: 'streak')))
        .thenAnswer((_) async {});

    return DailyCubit(
      content,
      lastArchetype,
      chains,
      Analytics(EventQueue(preferences), events),
      widget,
    );
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
}
