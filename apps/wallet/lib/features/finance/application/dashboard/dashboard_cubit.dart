import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/currency_usage.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';

/// Recomputes the dashboard whenever transactions, categories or budgets
/// change.
///
/// Because all three repositories expose streams, adding a transaction on the
/// entry screen updates the totals, the chart and the overspend warning here
/// without either screen knowing about the other.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._transactions, this._categories, this._budgets)
    : super(const DashboardLoading());

  final TransactionRepository _transactions;
  final CategoryRepository _categories;
  final BudgetRepository _budgets;

  final List<StreamSubscription<void>> _subscriptions = [];

  List<MoneyTransaction> _allTransactions = const [];
  List<Category> _allCategories = const [];
  List<Budget> _allBudgets = const [];

  MonthPeriod _period = MonthPeriod.of(DateTime.now());
  Currency? _currency;
  bool _hasTransactions = false;

  /// Subscribes to storage. Safe to call once per instance.
  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions.addAll([
      _transactions.watchAll().listen((items) {
        _allTransactions = items;
        _hasTransactions = true;
        _emitReady();
      }),
      _categories.watchAll().listen((items) {
        _allCategories = items;
        _emitReady();
      }),
      _budgets.watchAll().listen((items) {
        _allBudgets = items;
        _emitReady();
      }),
    ]);
  }

  void selectPeriod(MonthPeriod period) {
    _period = period;
    _emitReady();
  }

  void showPreviousMonth() => selectPeriod(_period.previous);

  void showNextMonth() => selectPeriod(_period.next);

  void selectCurrency(Currency currency) {
    _currency = currency;
    _emitReady();
  }

  void _emitReady() {
    // Wait for the first transaction emission so the screen does not flash an
    // "empty month" before storage has answered.
    if (!_hasTransactions) return;

    final available = currenciesUsed(_allTransactions);
    final currency = _resolveCurrency(available);
    final summary = MonthlySummary.from(
      transactions: _allTransactions,
      period: _period,
      currency: currency,
    );

    emit(
      DashboardReady(
        period: _period,
        currency: currency,
        availableCurrencies: available,
        summary: summary,
        budgetStatuses: BudgetEvaluator.evaluate(
          budgets: _allBudgets,
          summary: summary,
        ),
        categories: {
          for (final category in _allCategories) category.id: category,
        },
      ),
    );
  }

  /// Keeps the user's pick when it is still in use, otherwise falls back to
  /// the first currency they have data in.
  Currency _resolveCurrency(List<Currency> available) {
    final selected = _currency;
    if (selected != null && available.contains(selected)) return selected;
    return available.isNotEmpty ? available.first : Currency.turkishLira;
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
