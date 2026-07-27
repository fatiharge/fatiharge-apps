import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/application/history/history_effect.dart';
import 'package:wallet/features/finance/application/history/history_event.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/in_memory_repositories.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;

  setUp(() {
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository()..seed([categoryOf('food')]);
  });

  tearDown(() async {
    await transactions.dispose();
    await categories.dispose();
  });

  HistoryBloc build() => HistoryBloc(transactions, categories);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('HistoryBloc', () {
    test('loads everything, newest first', () async {
      transactions.seed([
        expenseOf(100, id: 'old', on: DateTime(2026, 7)),
        expenseOf(200, id: 'new', on: DateTime(2026, 7, 20)),
      ]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      expect(bloc.state.loading, isFalse);
      expect(bloc.state.visible.map((t) => t.id), ['new', 'old']);
    });

    test('applies a filter without re-reading storage', () async {
      transactions.seed([
        expenseOf(100, category: 'food'),
        incomeOf(900, category: 'salary'),
      ]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      bloc.add(
        const HistoryFilterChanged(
          TransactionFilter(type: TransactionType.income),
        ),
      );
      await settle();

      expect(bloc.state.visible, hasLength(1));
      // The unfiltered set is still in memory.
      expect(bloc.state.all, hasLength(2));
      expect(bloc.state.isFilteredEmpty, isFalse);
    });

    test('distinguishes "no results" from "nothing recorded"', () async {
      transactions.seed([expenseOf(100, category: 'food')]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      bloc.add(
        const HistoryFilterChanged(TransactionFilter(categoryIds: {'nope'})),
      );
      await settle();

      expect(bloc.state.isEmpty, isTrue);
      expect(bloc.state.isFilteredEmpty, isTrue);
    });

    test('clearing the filter brings everything back', () async {
      transactions.seed([expenseOf(100, category: 'food')]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      bloc.add(
        const HistoryFilterChanged(TransactionFilter(categoryIds: {'nope'})),
      );
      await settle();
      bloc.add(const HistoryFilterCleared());
      await settle();

      expect(bloc.state.visible, hasLength(1));
      expect(bloc.state.filter.isEmpty, isTrue);
    });

    test('deleting removes the row and fires an undo effect', () async {
      final transaction = expenseOf(100, id: 'gone', category: 'food');
      transactions.seed([transaction]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      final effects = <HistoryEffect>[];
      final subscription = bloc.effects.listen(effects.add);
      addTearDown(subscription.cancel);

      bloc.add(HistoryTransactionDeleted(transaction));
      await settle();

      expect(await transactions.fetchAll(), isEmpty);
      expect(bloc.state.visible, isEmpty);
      expect(effects.single, isA<HistoryTransactionRemoved>());
    });

    test('undo restores the row under its original id', () async {
      final transaction = expenseOf(100, id: 'gone', category: 'food');
      transactions.seed([transaction]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      bloc.add(HistoryTransactionDeleted(transaction));
      await settle();
      bloc.add(HistoryDeleteUndone(transaction));
      await settle();

      final restored = await transactions.fetchAll();
      expect(restored.single.id, 'gone');
      expect(bloc.state.visible, hasLength(1));
    });

    test('effects are one-shot: a late listener sees nothing', () async {
      final transaction = expenseOf(100, id: 'gone', category: 'food');
      transactions.seed([transaction]);

      final bloc = build()..add(const HistoryStarted());
      addTearDown(bloc.close);
      await settle();

      bloc.add(HistoryTransactionDeleted(transaction));
      await settle();

      // Subscribing after the fact must not replay the snackbar.
      final late = <HistoryEffect>[];
      final subscription = bloc.effects.listen(late.add);
      addTearDown(subscription.cancel);
      await settle();

      expect(late, isEmpty);
    });
  });
}
