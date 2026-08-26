import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/features/finance/application/budget/budget_state.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/finance/domain/rules/amount_input.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

@injectable
class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(
    this._budgets,
    this._transactions,
    this._categories,
    SettingsRepository settings, {
    @ignoreParam Clock clock = systemClock,
  }) : super(
         BudgetState.initial(
           now: clock(),
           currency: settings.readCurrency(),
         ),
       );

  final BudgetRepository _budgets;
  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  static const _uuid = Uuid();

  final List<StreamSubscription<void>> _subscriptions = [];

  List<Budget> _allBudgets = const [];
  List<MoneyTransaction> _allTransactions = const [];
  List<Category> _allCategories = const [];

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions.addAll([
      _budgets.watchAll().listen((items) {
        _allBudgets = items;
        _recompute();
      }),
      _transactions.watchAll().listen((items) {
        _allTransactions = items;
        _recompute();
      }),
      _categories.watchAll().listen((items) {
        _allCategories = items;
        _recompute();
      }),
    ]);
  }

  void selectCurrency(Currency currency) {
    emit(state.copyWith(currency: currency));
    _recompute();
  }

  /// Creates or replaces a limit. [categoryId] of `null` is the overall
  /// budget. Returns `false` when [amountText] is not a positive number.
  Future<bool> saveLimit({
    required String amountText,
    String? categoryId,
    String? budgetId,
  }) async {
    final limit = readAmount(amountText, state.currency).money;
    if (limit == null) return false;

    await _budgets.save(
      Budget(
        id: budgetId ?? _uuid.v4(),
        limit: limit,
        categoryId: categoryId,
      ),
    );
    return true;
  }

  Future<void> deleteLimit(String id) => _budgets.delete(id);

  void _recompute() {
    final summary = MonthlySummary.from(
      transactions: _allTransactions,
      period: state.period,
      currency: state.currency,
    );

    emit(
      state.copyWith(
        loading: false,
        statuses: BudgetEvaluator.evaluate(
          budgets: _allBudgets,
          summary: summary,
        ),
        categories: {
          for (final category in _allCategories) category.id: category,
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
