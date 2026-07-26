import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';

/// Why the entry form cannot be submitted yet.
enum EntryError { amountMissing, amountInvalid, amountNotPositive, noCategory }

/// The add/edit transaction form.
///
/// The amount is held as raw [amountText] rather than a parsed [Money]: the
/// user types `12,` on the way to `12,50`, and a state that cannot represent
/// half-typed input forces the widget to keep its own shadow copy.
@immutable
class EntryState {
  const EntryState({
    required this.type,
    required this.currency,
    required this.date,
    this.editingId,
    this.amountText = '',
    this.categoryId,
    this.note = '',
    this.categories = const [],
    this.submitting = false,
    this.saved = false,
    this.showErrors = false,
  });

  EntryState.initial({DateTime? now})
    : this(
        type: TransactionType.expense,
        currency: Currency.turkishLira,
        date: now ?? DateTime.now(),
      );

  /// Set when editing an existing transaction; `null` when adding a new one.
  final String? editingId;
  final TransactionType type;
  final Currency currency;
  final DateTime date;
  final String amountText;
  final String? categoryId;
  final String note;

  /// Selectable categories (archived ones excluded).
  final List<Category> categories;

  final bool submitting;
  final bool saved;

  /// Errors stay hidden until the first submit attempt.
  final bool showErrors;

  bool get isEditing => editingId != null;

  Money? get amount => Money.tryParse(amountText, currency);

  EntryError? get error {
    if (amountText.trim().isEmpty) return EntryError.amountMissing;
    final parsed = amount;
    if (parsed == null) return EntryError.amountInvalid;
    if (parsed.amountMinor <= 0) return EntryError.amountNotPositive;
    if (categoryId == null) return EntryError.noCategory;
    return null;
  }

  bool get isValid => error == null;

  /// The error to render, or `null` while the user has not submitted yet.
  EntryError? get visibleError => showErrors ? error : null;

  EntryState copyWith({
    String? editingId,
    TransactionType? type,
    Currency? currency,
    DateTime? date,
    String? amountText,
    String? categoryId,
    String? note,
    List<Category>? categories,
    bool? submitting,
    bool? saved,
    bool? showErrors,
  }) => EntryState(
    editingId: editingId ?? this.editingId,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    date: date ?? this.date,
    amountText: amountText ?? this.amountText,
    categoryId: categoryId ?? this.categoryId,
    note: note ?? this.note,
    categories: categories ?? this.categories,
    submitting: submitting ?? this.submitting,
    saved: saved ?? this.saved,
    showErrors: showErrors ?? this.showErrors,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryState &&
          other.editingId == editingId &&
          other.type == type &&
          other.currency == currency &&
          other.date == date &&
          other.amountText == amountText &&
          other.categoryId == categoryId &&
          other.note == note &&
          listEquals(other.categories, categories) &&
          other.submitting == submitting &&
          other.saved == saved &&
          other.showErrors == showErrors;

  @override
  int get hashCode => Object.hash(
    editingId,
    type,
    currency,
    date,
    amountText,
    categoryId,
    note,
    Object.hashAll(categories),
    submitting,
    saved,
    showErrors,
  );
}
