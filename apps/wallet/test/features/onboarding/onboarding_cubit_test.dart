import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/onboarding/application/onboarding_cubit.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';

import '../../support/finance_fixtures.dart';
import '../../support/in_memory_repositories.dart';

void main() {
  late FakeCategoryRepository categories;
  late FakeSettingsRepository settings;
  late OnboardingCubit cubit;

  setUp(() {
    categories = FakeCategoryRepository()
      ..seed([
        categoryOf('food', nameKey: 'category.food'),
        categoryOf('transport', nameKey: 'category.transport'),
        categoryOf('gift', nameKey: 'category.gift'),
      ]);
    settings = FakeSettingsRepository(onboarded: false);
    cubit = OnboardingCubit(categories, settings);
  });

  tearDown(() async {
    await cubit.close();
    await categories.dispose();
  });

  test('opens with every seeded category kept', () async {
    await cubit.start();

    expect(cubit.state.keptCategoryIds, {'food', 'transport', 'gift'});
    expect(cubit.state.step, OnboardingStep.welcome);
    expect(cubit.state.stepNumber, 1);
  });

  test('walks forward and back without running off either end', () async {
    expect(cubit.state.isFirst, isTrue);

    cubit.back();
    expect(cubit.state.step, OnboardingStep.welcome);

    for (var i = 0; i < OnboardingStep.values.length + 2; i++) {
      cubit.next();
    }
    expect(cubit.state.step, OnboardingStep.categories);
    expect(cubit.state.isLast, isTrue);

    cubit.back();
    expect(cubit.state.step, OnboardingStep.currency);
  });

  test('archives what was unticked and leaves the rest alone', () async {
    await cubit.start();

    cubit.toggleCategory('gift', keep: false);
    await cubit.finish();

    final stored = {for (final c in await categories.fetchAll()) c.id: c};
    expect(stored['gift']!.archived, isTrue);
    expect(stored['food']!.archived, isFalse);
    expect(stored['transport']!.archived, isFalse);

    // Archived, never deleted: a transaction pointing at it still resolves.
    expect(stored, hasLength(3));
  });

  test('unticking then reticking leaves the category alone', () async {
    await cubit.start();

    cubit
      ..toggleCategory('gift', keep: false)
      ..toggleCategory('gift', keep: true);
    await cubit.finish();

    final stored = await categories.fetchAll();
    expect(stored.every((c) => !c.archived), isTrue);
  });

  test('finishing records that the flow has been through', () async {
    await cubit.start();
    await cubit.finish();

    expect(settings.onboarded, isTrue);
    expect(cubit.state.finished, isTrue);
  });

  test('skipping records it too, and archives nothing', () async {
    await cubit.start();

    cubit.toggleCategory('gift', keep: false);
    await cubit.skip();

    expect(settings.onboarded, isTrue);
    expect(cubit.state.finished, isTrue);
    expect((await categories.fetchAll()).every((c) => !c.archived), isTrue);
  });

  test('a category already archived is not archived again', () async {
    categories.seed([categoryOf('old', name: 'Eski', archived: true)]);
    await cubit.start();

    expect(cubit.state.keptCategoryIds, isNot(contains('old')));

    await cubit.finish();

    final stored = {for (final c in await categories.fetchAll()) c.id: c};
    expect(stored['old']!.archived, isTrue);
  });
}
