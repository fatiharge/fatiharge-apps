import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/default_categories.dart';
import 'package:wallet/features/finance/presentation/views/transaction_tile.dart';

import '../../../../support/finance_fixtures.dart';
import '../../../../support/widget_harness.dart';

/// Seeded names used to be translated once at first launch and stored as text,
/// so an install that first ran in Turkish stayed Turkish.
void main() {
  Future<void> switchToEnglish(WidgetTester tester) async {
    final context = tester.element(find.byType(TransactionTile));
    await context.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
  }

  test('seeded categories carry a key, never a translated name', () {
    for (final category in defaultCategories()) {
      expect(category.nameKey, isNotNull, reason: category.id);
      expect(category.name, isNull, reason: category.id);
    }
  });

  testWidgets('a seeded name follows the language', (tester) async {
    await pumpLocalized(
      tester,
      TransactionTile(
        transaction: expenseOf(2500, category: 'food'),
        category: categoryOf('food', nameKey: 'category.food'),
      ),
    );

    expect(find.text('Yemek'), findsOneWidget);

    await switchToEnglish(tester);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Yemek'), findsNothing);
  });

  testWidgets('a name the user typed survives the language switch', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      TransactionTile(
        transaction: expenseOf(2500, category: 'food'),
        category: categoryOf('food', name: 'Market'),
      ),
    );

    expect(find.text('Market'), findsOneWidget);

    await switchToEnglish(tester);

    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });
}
