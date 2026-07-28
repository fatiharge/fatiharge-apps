import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/presentation/views/transaction_entry_view.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  late TextEditingController amount;
  late TextEditingController note;
  final types = <TransactionType>[];
  final categories = <String>[];
  var submitted = 0;

  setUp(() {
    amount = TextEditingController();
    note = TextEditingController();
    types.clear();
    categories.clear();
    submitted = 0;
  });

  tearDown(() {
    amount.dispose();
    note.dispose();
  });

  Future<void> pump(
    WidgetTester tester, {
    bool isEditing = false,
    bool submitting = false,
    String? amountError,
    String? selectedCategoryId = 'food',
  }) => pumpLocalized(
    tester,
    TransactionEntryView(
      amountController: amount,
      noteController: note,
      isEditing: isEditing,
      type: TransactionType.expense,
      currency: Currency.turkishLira,
      date: DateTime(2026, 7, 15),
      categories: [
        categoryOf('food', name: 'Yemek'),
        categoryOf('transport', name: 'Ulaşım'),
      ],
      selectedCategoryId: selectedCategoryId,
      submitting: submitting,
      amountError: amountError,
      onTypeChanged: types.add,
      onAmountChanged: (_) {},
      onCurrencyChanged: (_) {},
      onCategorySelected: categories.add,
      onDateSelected: (_) {},
      onNoteChanged: (_) {},
      onSubmit: () => submitted++,
    ),
    // A spinner never stops scheduling frames.
    settle: !submitting,
  );

  group('TransactionEntryView', () {
    testWidgets('adding and editing are titled differently', (tester) async {
      await pump(tester);
      expect(find.text('Kayıt ekle'), findsOneWidget);

      await pump(tester, isEditing: true);
      expect(find.text('Kaydı düzenle'), findsOneWidget);
      expect(find.text('Kayıt ekle'), findsNothing);
    });

    testWidgets('shows the amount error it is handed', (tester) async {
      await pump(tester, amountError: 'Tutar sıfırdan büyük olmalı');

      expect(find.text('Tutar sıfırdan büyük olmalı'), findsOneWidget);
    });

    testWidgets('shows no error text when there is none', (tester) async {
      await pump(tester);

      expect(find.text('Tutar sıfırdan büyük olmalı'), findsNothing);
    });

    testWidgets('save reports a submit', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Kaydet'));

      expect(submitted, 1);
    });

    testWidgets('while submitting the button is disabled, not just spinning', (
      tester,
    ) async {
      // A spinner over a live button is how a double-save happens.
      await pump(tester, submitting: true);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Kaydet'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('switching to income reports the new type', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Gelir'));

      expect(types.single, TransactionType.income);
    });

    testWidgets('picking a category reports its id', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Ulaşım'));

      expect(categories.single, 'transport');
    });

    testWidgets('the date is rendered in the pinned locale', (tester) async {
      await pump(tester);

      // Proves the harness really localises: an unlocalised DateFormat would
      // render "Jul" here.
      expect(find.textContaining('Tem'), findsOneWidget);
    });
  });
}
