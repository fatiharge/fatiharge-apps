import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/presentation/views/category_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/category_view.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  group('CategoryView', () {
    Future<void> pumpView(
      WidgetTester tester, {
      List<Category> active = const [],
      List<Category> archived = const [],
      ValueChanged<Category>? onArchive,
      ValueChanged<Category>? onRestore,
    }) => pumpLocalized(
      tester,
      CategoryView(
        active: active,
        archived: archived,
        onAdd: () {},
        onArchive: onArchive ?? (_) {},
        onRestore: onRestore ?? (_) {},
      ),
    );

    testWidgets('a seeded category shows its translated name', (tester) async {
      await pumpView(
        tester,
        active: [categoryOf('food', nameKey: 'category.food')],
      );

      expect(find.text('Yemek'), findsOneWidget);
    });

    testWidgets('the archived section appears only once something is in it', (
      tester,
    ) async {
      await pumpView(tester, active: [categoryOf('food', name: 'Yemek')]);

      expect(find.text('Arşivlenenler'), findsNothing);

      await pumpView(
        tester,
        active: [categoryOf('food', name: 'Yemek')],
        archived: [categoryOf('old', name: 'Eski')],
      );

      expect(find.text('Arşivlenenler'), findsOneWidget);
      expect(find.text('Eski'), findsOneWidget);
    });

    testWidgets('each row offers the action its section allows', (
      tester,
    ) async {
      final archived = <String>[];
      final restored = <String>[];

      await pumpView(
        tester,
        active: [categoryOf('food', name: 'Yemek')],
        archived: [categoryOf('old', name: 'Eski')],
        onArchive: (c) => archived.add(c.id),
        onRestore: (c) => restored.add(c.id),
      );

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.tap(find.byIcon(Icons.unarchive_outlined));
      await tester.pumpAndSettle();

      expect(archived, ['food']);
      expect(restored, ['old']);
    });

    testWidgets('an empty store explains itself rather than showing nothing', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('Kategori yok'), findsOneWidget);
    });
  });

  group('CategoryEditorSheet', () {
    CategoryDraft? returned;

    /// Opened the way the page opens it. Without `isScrollControlled` the
    /// sheet is capped at a fraction of the screen, the save button falls
    /// outside it, and a tap meant for it lands on the barrier instead —
    /// dismissing the sheet rather than submitting.
    Future<void> openSheet(WidgetTester tester) async {
      returned = null;
      await pumpLocalized(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showModalBottomSheet<CategoryDraft>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const CategoryEditorSheet(),
              );
            },
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> tapSave(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Kaydet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
    }

    testWidgets('a blank name is refused rather than returned', (tester) async {
      await openSheet(tester);
      await tapSave(tester);

      expect(find.text('Bir ad gir'), findsOneWidget);
      expect(find.byType(CategoryEditorSheet), findsOneWidget);
      expect(returned, isNull);
    });

    testWidgets('hands back the name, icon and colour that were picked', (
      tester,
    ) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextField), 'Abonelikler');
      await tester.ensureVisible(find.byIcon(Icons.receipt_long_outlined));
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(returned?.name, 'Abonelikler');
      expect(returned?.icon, CategoryIcon.bills);
      expect(categoryPalette, contains(returned?.colorArgb));
    });
  });
}
