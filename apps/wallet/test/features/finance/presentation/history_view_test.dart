import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/presentation/views/history_view.dart';
import 'package:wallet/features/finance/presentation/views/transaction_tile.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  final deleted = <MoneyTransaction>[];
  final edited = <MoneyTransaction>[];
  var filterCleared = 0;

  setUp(() {
    deleted.clear();
    edited.clear();
    filterCleared = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    required List<MoneyTransaction> transactions,
    bool isFiltered = false,
    Map<String, Category> categories = const {},
  }) => pumpLocalized(
    tester,
    HistoryView(
      transactions: transactions,
      categories: categories,
      isFiltered: isFiltered,
      onDelete: deleted.add,
      onEdit: edited.add,
      onClearFilter: () => filterCleared++,
    ),
  );

  group('HistoryView', () {
    testWidgets('an empty history explains that nothing is recorded yet', (
      tester,
    ) async {
      await pump(tester, transactions: []);

      expect(find.text('Geçmiş boş'), findsOneWidget);
      expect(find.text('Filtreye uyan kayıt yok'), findsNothing);
    });

    testWidgets('an empty *filtered* history says so instead', (tester) async {
      // The distinction the view exists to make: the same empty list means
      // two different things, and only one of them is the user's own doing.
      await pump(tester, transactions: [], isFiltered: true);

      expect(find.text('Filtreye uyan kayıt yok'), findsOneWidget);
      expect(find.text('Geçmiş boş'), findsNothing);
    });

    testWidgets('only the filtered empty state offers a way out', (
      tester,
    ) async {
      await pump(tester, transactions: [], isFiltered: true);

      await tester.tap(find.text('Filtreyi temizle'));

      expect(filterCleared, 1);
    });

    testWidgets('draws one tile per transaction', (tester) async {
      await pump(
        tester,
        transactions: [expenseOf(1000), incomeOf(2500), expenseOf(300)],
      );

      expect(find.byType(TransactionTile), findsNWidgets(3));
    });

    testWidgets('tapping a row asks to edit that transaction', (tester) async {
      final target = expenseOf(1000, id: 'target');
      await pump(tester, transactions: [incomeOf(50), target]);

      await tester.tap(find.byType(TransactionTile).last);

      expect(edited.single.id, 'target');
    });

    testWidgets('swiping a row away asks to delete that transaction', (
      tester,
    ) async {
      final target = expenseOf(1000, id: 'target');
      await pump(tester, transactions: [target, incomeOf(50)]);

      await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(deleted.single.id, 'target');
    });

    testWidgets('a swipe the other way does not delete', (tester) async {
      // endToStart only: a left-to-right drag is how a user scrolls back, and
      // making it destructive would be a trap.
      await pump(tester, transactions: [expenseOf(1000)]);

      await tester.drag(find.byType(Dismissible).first, const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(deleted, isEmpty);
    });
  });
}
