import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/application/budget/budget_state.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';
import 'package:wallet/features/finance/presentation/views/budget_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/history_filter_sheet.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  const period = MonthPeriod(2026, 7);
  final food = categoryOf('food', name: 'Yemek');
  final transport = categoryOf('transport', name: 'Ulaşım');

  group('BudgetEditorSheet', () {
    BudgetState stateWith({List<BudgetStatus> statuses = const []}) =>
        BudgetState(
          period: period,
          categories: {food.id: food, transport.id: transport},
          statuses: statuses,
          loading: false,
        );

    testWidgets('a new limit starts with an empty amount', (tester) async {
      await pumpLocalized(tester, BudgetEditorSheet(state: stateWith()));

      expect(find.text('Limit ekle'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    });

    testWidgets('editing seeds the field with the existing limit', (
      tester,
    ) async {
      await pumpLocalized(
        tester,
        BudgetEditorSheet(
          state: stateWith(),
          existing: budgetOf(15000, category: 'food'),
        ),
      );

      expect(find.text('Limiti düzenle'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '150.00',
      );
    });

    testWidgets('an empty amount is refused rather than saved', (tester) async {
      BudgetDraft? returned;
      await pumpLocalized(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showModalBottomSheet<BudgetDraft>(
                context: context,
                builder: (_) => BudgetEditorSheet(state: stateWith()),
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(returned, isNull, reason: 'the sheet must stay open');
      expect(find.text('Geçerli bir limit gir'), findsOneWidget);
    });

    testWidgets('a valid amount is handed back as a draft', (tester) async {
      BudgetDraft? returned;
      await pumpLocalized(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showModalBottomSheet<BudgetDraft>(
                context: context,
                builder: (_) => BudgetEditorSheet(state: stateWith()),
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '250');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(returned?.amountText, '250');
    });
  });

  group('HistoryFilterSheet', () {
    Future<void> open(WidgetTester tester, TransactionFilter filter) =>
        pumpLocalized(
          tester,
          HistoryFilterSheet(filter: filter, categories: [food, transport]),
        );

    testWidgets('offers every category as a chip', (tester) async {
      await open(tester, const TransactionFilter());

      expect(find.widgetWithText(FilterChip, 'Yemek'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Ulaşım'), findsOneWidget);
    });

    testWidgets('reflects the filter it was opened with', (tester) async {
      await open(
        tester,
        const TransactionFilter(type: TransactionType.income),
      );

      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Gelir'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('clearing returns an empty filter, not null', (tester) async {
      TransactionFilterResult? result;
      await pumpLocalized(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showModalBottomSheet<TransactionFilterResult>(
                context: context,
                builder: (_) => HistoryFilterSheet(
                  filter: const TransactionFilter(
                    type: TransactionType.expense,
                  ),
                  categories: [food],
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filtreyi temizle'));
      await tester.pumpAndSettle();

      expect(result, isNotNull, reason: 'cleared is not the same as cancelled');
      expect(result!.filter.type, isNull);
    });
  });
}
