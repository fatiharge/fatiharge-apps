import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

import '../../support/finance_fixtures.dart';
import '../../support/in_memory_repositories.dart';
import '../../support/widget_harness.dart';

void main() {
  late FakeSettingsRepository settings;

  setUp(() async {
    settings = FakeSettingsRepository(onboarded: false);
    await getIt.reset();
    getIt.registerSingleton<SettingsRepository>(settings);
  });

  tearDown(getIt.reset);

  var skipped = 0;
  var finished = 0;
  final toggled = <String, bool>{};

  Future<void> pumpStep(
    WidgetTester tester,
    OnboardingStep step, {
    Set<String> kept = const {'food', 'gift'},
  }) {
    skipped = 0;
    finished = 0;
    toggled.clear();
    useTallSurface(tester);

    return pumpLocalized(
      tester,
      BlocProvider(
        create: (_) => SettingsCubit(settings),
        child: OnboardingView(
          state: OnboardingState(
            step: step,
            categories: [
              categoryOf('food', nameKey: 'category.food'),
              categoryOf('gift', nameKey: 'category.gift'),
            ],
            keptCategoryIds: kept,
          ),
          onNext: () {},
          onBack: () {},
          onSkip: () => skipped++,
          onFinish: () => finished++,
          onToggleCategory: (id, {required keep}) => toggled[id] = keep,
        ),
      ),
    );
  }

  testWidgets('the welcome step introduces the app', (tester) async {
    await pumpStep(tester, OnboardingStep.welcome);

    expect(find.text("Warizo'ya hoş geldin"), findsOneWidget);
    expect(find.text('Adım 1/5'), findsOneWidget);
    expect(find.text('Geri'), findsNothing);
  });

  testWidgets('skip is on every step, not just the first', (tester) async {
    for (final step in OnboardingStep.values) {
      await pumpStep(tester, step);

      expect(find.text('Atla'), findsOneWidget, reason: '$step');

      await tester.tap(find.text('Atla'));
      await tester.pumpAndSettle();
      expect(skipped, 1, reason: '$step');
    }
  });

  testWidgets('each step shows the control it is about', (tester) async {
    await pumpStep(tester, OnboardingStep.language);
    expect(find.text('Türkçe'), findsOneWidget);

    await pumpStep(tester, OnboardingStep.theme);
    expect(find.text('Koyu'), findsOneWidget);

    await pumpStep(tester, OnboardingStep.currency);
    expect(find.text('₺  TRY'), findsOneWidget);
  });

  testWidgets('the category step starts with everything ticked', (
    tester,
  ) async {
    await pumpStep(tester, OnboardingStep.categories);

    expect(find.text('Yemek'), findsOneWidget);
    expect(find.text('Hediye'), findsOneWidget);
    for (final tile in tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    )) {
      expect(tile.value, isTrue);
    }
  });

  testWidgets('unticking a category reports it up', (tester) async {
    await pumpStep(tester, OnboardingStep.categories);

    await tester.tap(find.text('Hediye'));
    await tester.pumpAndSettle();

    expect(toggled, {'gift': false});
  });

  testWidgets('the last step finishes rather than advancing', (tester) async {
    await pumpStep(tester, OnboardingStep.categories);

    expect(find.text('Başla'), findsOneWidget);
    expect(find.text('İleri'), findsNothing);

    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();

    expect(finished, 1);
  });
}
