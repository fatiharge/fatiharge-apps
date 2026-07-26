import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:utility_kit/utility_kit.dart';
import 'package:wallet/app/features/finance/application/history/history_effect.dart';
import 'package:wallet/app/features/finance/application/history/history_event.dart';
import 'package:wallet/app/features/finance/application/history/history_state.dart';
import 'package:wallet/app/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/app/features/finance/domain/repository/transaction_repository.dart';

/// The transaction history: filtering, and delete with undo.
///
/// An [EffectBloc] because deleting has to both change state (the row goes
/// away) and fire a one-shot action (show the undo snackbar). Putting the
/// snackbar in state would re-show it on every rebuild.
@injectable
class HistoryBloc extends EffectBloc<HistoryEvent, HistoryState, HistoryEffect> {
  HistoryBloc(this._transactions, this._categories)
    : super(const HistoryState()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryDataReceived>(_onDataReceived);
    on<HistoryFilterChanged>(_onFilterChanged);
    on<HistoryFilterCleared>(_onFilterCleared);
    on<HistoryTransactionDeleted>(_onDeleted);
    on<HistoryDeleteUndone>(_onUndone);
  }

  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  final List<StreamSubscription<void>> _subscriptions = [];

  void _onStarted(HistoryStarted event, Emitter<HistoryState> emit) {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions.addAll([
      _transactions.watchAll().listen(
        (items) => add(HistoryDataReceived(transactions: items)),
      ),
      _categories.watchAll().listen(
        (items) => add(HistoryDataReceived(categories: items)),
      ),
    ]);
  }

  void _onDataReceived(HistoryDataReceived event, Emitter<HistoryState> emit) {
    emit(
      state.copyWith(
        all: event.transactions,
        categories: event.categories == null
            ? null
            : {for (final category in event.categories!) category.id: category},
        loading: false,
      ),
    );
  }

  void _onFilterChanged(
    HistoryFilterChanged event,
    Emitter<HistoryState> emit,
  ) => emit(state.copyWith(filter: event.filter));

  void _onFilterCleared(
    HistoryFilterCleared event,
    Emitter<HistoryState> emit,
  ) => emit(state.copyWith(filter: const TransactionFilter()));

  Future<void> _onDeleted(
    HistoryTransactionDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    await _transactions.delete(event.transaction.id);
    // The list itself refreshes through the stream; this only drives the
    // snackbar.
    emitEffect(HistoryTransactionRemoved(event.transaction));
  }

  Future<void> _onUndone(
    HistoryDeleteUndone event,
    Emitter<HistoryState> emit,
  ) async {
    // Re-saving under the original id restores the row exactly where it was.
    await _transactions.save(event.transaction);
    emitEffect(const HistoryDeleteRestored());
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
