import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/app/features/finance/application/entry/entry_state.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';

import '../../../../support/finance_fixtures.dart';
import '../../../../support/in_memory_repositories.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;

  setUp(() {
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository()
      ..seed([
        categoryOf('food', name: 'Yemek'),
        categoryOf('rent', name: 'Kira'),
        categoryOf('old', name: 'Eski', archived: true),
      ]);
  });

  tearDown(() async {
    await transactions.dispose();
    await categories.dispose();
  });

  EntryCubit build() => EntryCubit(transactions, categories);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('EntryCubit', () {
    test(
      'offers only unarchived categories and preselects the first',
      () async {
        final cubit = build()..start();
        addTearDown(cubit.close);
        await settle();

        expect(cubit.state.categories.map((c) => c.id), ['food', 'rent']);
        expect(cubit.state.categoryId, 'food');
      },
    );

    test('rejects an empty, unparsable or non-positive amount', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.error, EntryError.amountMissing);

      cubit.amountChanged('abc');
      expect(cubit.state.error, EntryError.amountInvalid);

      cubit.amountChanged('0');
      expect(cubit.state.error, EntryError.amountNotPositive);

      cubit.amountChanged('12,50');
      expect(cubit.state.error, isNull);
    });

    test('hides errors until the first submit', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.visibleError, isNull);

      await cubit.submit();

      expect(cubit.state.visibleError, EntryError.amountMissing);
      expect(cubit.state.saved, isFalse);
      expect(await transactions.fetchAll(), isEmpty);
    });

    test('saves a valid entry with the parsed amount', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      cubit
        ..amountChanged('12,50')
        ..categorySelected('rent')
        ..noteChanged('  Ocak kirası  ');
      await cubit.submit();

      final saved = (await transactions.fetchAll()).single;
      expect(saved.amount, const Money(1250, Currency.turkishLira));
      expect(saved.categoryId, 'rent');
      expect(saved.type, TransactionType.expense);
      expect(saved.note, 'Ocak kirası');
      expect(cubit.state.saved, isTrue);
    });

    test('a blank note is stored as null, not as whitespace', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      cubit
        ..amountChanged('10')
        ..noteChanged('   ');
      await cubit.submit();

      expect((await transactions.fetchAll()).single.note, isNull);
    });

    test('keeps the currency chosen for the amount', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      cubit
        ..currencyChanged(Currency.euro)
        ..amountChanged('7,25');
      await cubit.submit();

      expect(
        (await transactions.fetchAll()).single.amount,
        const Money(725, Currency.euro),
      );
    });

    test(
      'editing keeps the id, so it updates instead of duplicating',
      () async {
        final existing = expenseOf(5000, category: 'food', id: 'keep-me');
        await transactions.save(existing);

        final cubit = build()..start(existing: existing);
        addTearDown(cubit.close);
        await settle();

        expect(cubit.state.isEditing, isTrue);
        expect(cubit.state.amountText, '50.00');

        cubit.amountChanged('75');
        await cubit.submit();

        final all = await transactions.fetchAll();
        expect(all, hasLength(1));
        expect(all.single.id, 'keep-me');
        expect(all.single.amount, const Money(7500, Currency.turkishLira));
      },
    );
  });
}
