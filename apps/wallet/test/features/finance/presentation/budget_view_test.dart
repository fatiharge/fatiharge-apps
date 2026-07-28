import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/features/finance/presentation/views/budget_view.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  const period = MonthPeriod(2026, 7);
  var addTapped = 0;
  final edited = <BudgetStatus>[];

  setUp(() {
    addTapped = 0;
    edited.clear();
  });

  List<BudgetStatus> statusesFor(List<int> limits, {int spent = 1000}) =>
      BudgetEvaluator.evaluate(
        budgets: [
          for (final (index, limit) in limits.indexed)
            budgetOf(limit, id: 'b$index', category: 'misc'),
        ],
        summary: MonthlySummary.from(
          transactions: [expenseOf(spent)],
          period: period,
          currency: Currency.turkishLira,
        ),
      );

  Future<void> pump(WidgetTester tester, List<BudgetStatus> statuses) =>
      pumpLocalized(
        tester,
        BudgetView(
          statuses: statuses,
          categories: {'misc': categoryOf('misc', name: 'Diğer')},
          onAdd: () => addTapped++,
          onEdit: edited.add,
          onDelete: (_) {},
        ),
      );

  group('BudgetView', () {
    testWidgets('with no budgets it explains what they are for', (
      tester,
    ) async {
      await pump(tester, const []);

      expect(find.text('Henüz bütçe yok'), findsOneWidget);
      expect(
        find.text('Aylık limit belirle, aşınca uyaralım.'),
        findsOneWidget,
      );
    });

    testWidgets('the empty state is the only way in for a first budget', (
      tester,
    ) async {
      await pump(tester, const []);

      await tester.tap(find.text('Limit ekle'));

      expect(addTapped, 1);
    });

    testWidgets('draws one tile per budget', (tester) async {
      await pump(tester, statusesFor([5000, 8000, 12000]));

      expect(find.byType(BudgetProgressTile), findsNWidgets(3));
    });

    testWidgets('a populated list drops the empty state', (tester) async {
      await pump(tester, statusesFor([5000]));

      expect(find.text('Henüz bütçe yok'), findsNothing);
    });

    testWidgets('tapping a tile asks to edit that budget', (tester) async {
      final statuses = statusesFor([5000, 8000]);
      await pump(tester, statuses);

      await tester.tap(find.byType(BudgetProgressTile).first);

      expect(edited.single.budget.id, statuses.first.budget.id);
    });
  });
}
