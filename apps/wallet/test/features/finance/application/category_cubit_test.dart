import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/application/category/category_cubit.dart';
import 'package:wallet/features/finance/domain/models/category.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/in_memory_repositories.dart';

void main() {
  late FakeCategoryRepository categories;
  late CategoryCubit cubit;

  setUp(() {
    categories = FakeCategoryRepository();
    cubit = CategoryCubit(categories);
  });

  tearDown(() async {
    await cubit.close();
    await categories.dispose();
  });

  test('splits what storage holds into active and archived', () async {
    categories.seed([
      categoryOf('food', name: 'Yemek'),
      categoryOf('old', name: 'Eski', archived: true),
    ]);
    cubit.start();
    await pumpEventQueue();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.active.map((c) => c.id), ['food']);
    expect(cubit.state.archived.map((c) => c.id), ['old']);
  });

  test("an added category is the user's own, not a seeded key", () async {
    cubit.start();
    await pumpEventQueue();

    final added = await cubit.add(
      name: '  Abonelikler  ',
      icon: CategoryIcon.bills,
      colorArgb: 0xFF64B5F6,
    );
    await pumpEventQueue();

    expect(added, isTrue);
    final category = cubit.state.active.single;
    expect(category.name, 'Abonelikler');
    // A nameKey would make the language switch overwrite what they typed.
    expect(category.nameKey, isNull);
    expect(category.icon, CategoryIcon.bills);
    expect(category.archived, isFalse);
  });

  test('a blank name is refused rather than stored', () async {
    cubit.start();
    await pumpEventQueue();

    final added = await cubit.add(
      name: '   ',
      icon: CategoryIcon.other,
      colorArgb: 0xFF90A4AE,
    );
    await pumpEventQueue();

    expect(added, isFalse);
    expect(cubit.state.categories, isEmpty);
  });

  test('archiving hides a category without destroying it', () async {
    categories.seed([categoryOf('food', name: 'Yemek')]);
    cubit.start();
    await pumpEventQueue();

    await cubit.archive('food');
    await pumpEventQueue();

    expect(cubit.state.active, isEmpty);
    // Still on record: transactions reference categories by id and have to
    // keep resolving one.
    expect(cubit.state.archived.single.id, 'food');
    expect(await categories.fetchAll(), hasLength(1));
  });

  test('restoring brings it back to the pickers', () async {
    categories.seed([categoryOf('food', name: 'Yemek', archived: true)]);
    cubit.start();
    await pumpEventQueue();

    await cubit.restore('food');
    await pumpEventQueue();

    expect(cubit.state.active.single.id, 'food');
    expect(cubit.state.archived, isEmpty);
  });
}
