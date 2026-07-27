import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/infrastructure/repository/category_repository_impl.dart';

import '../../support/finance_fixtures.dart';
import '../../support/hive_harness.dart';

void main() {
  late HiveHarness hive;
  late CategoryRepository repository;

  setUp(() async {
    hive = HiveHarness();
    await hive.open();
    repository = CategoryRepositoryImpl(hive.storage);
  });

  tearDown(() => hive.close());

  group('CategoryRepositoryImpl', () {
    test('a saved category comes back identical', () async {
      const category = Category(
        id: 'food',
        name: 'Yemek',
        icon: CategoryIcon.food,
        colorArgb: 0xFFE57373,
      );

      await repository.save(category);

      expect((await repository.fetchAll()).single, category);
    });

    test('archiving flips the flag and keeps the record', () async {
      await repository.save(categoryOf('food'));

      await repository.archive('food');

      final stored = (await repository.fetchAll()).single;
      expect(stored.id, 'food');
      expect(stored.archived, isTrue);
    });

    test('restore flips it back', () async {
      await repository.save(categoryOf('food', archived: true));

      await repository.restore('food');

      expect((await repository.fetchAll()).single.archived, isFalse);
    });

    test('archiving an unknown id changes nothing', () async {
      await repository.save(categoryOf('food'));

      await repository.archive('never-existed');

      expect(await repository.fetchAll(), hasLength(1));
      expect((await repository.fetchAll()).single.archived, isFalse);
    });

    test('the archived flag survives a reopen', () async {
      await repository.save(categoryOf('food'));
      await repository.archive('food');

      await hive.reopen();
      final reopened = CategoryRepositoryImpl(hive.storage);

      expect((await reopened.fetchAll()).single.archived, isTrue);
    });

    test('watchAll emits after an archive', () async {
      await repository.save(categoryOf('food'));

      final seen = <bool>[];
      final subscription = repository.watchAll().listen(
        (items) => seen.add(items.single.archived),
      );
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);

      await repository.archive('food');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [false, true]);
    });
  });
}
