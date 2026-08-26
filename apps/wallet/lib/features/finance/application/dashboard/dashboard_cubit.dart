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
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/domain/rules/currency_usage.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

/// Recomputes the dashboard whenever transactions, categories or budgets
/// change.
///
/// Because all three repositories expose streams, adding a transaction on the
/// entry screen updates the totals, the chart and the overspend warning here
/// without either screen knowing about the other.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._transactions,
    this._categories,
    this._budgets,
    this._settings, {
    @ignoreParam this.clock = systemClock,
  }) : super(const DashboardLoading());

  final TransactionRepository _transactions;
  final CategoryRepository _categories;
  final BudgetRepository _budgets;
  final SettingsRepository _settings;

  final Clock clock;

  final List<StreamSubscription<void>> _subscriptions = [];

  List<MoneyTransaction> _allTransactions = const [];
  List<Category> _allCategories = const [];
  List<Budget> _allBudgets = const [];

  late MonthPeriod _period = MonthPeriod.of(clock());
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

  /// Browsing stops at the current month; there is nothing recorded past today.
  void showNextMonth() {
    if (!_canShowNextMonth) return;
    selectPeriod(_period.next);
  }

  bool get _canShowNextMonth => _period.isBefore(MonthPeriod.of(clock()));

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
        canShowNextMonth: _canShowNextMonth,
        budgetStatuses: BudgetEvaluator.evaluate(
          budgets: _allBudgets,
          summary: summary,
        ),
        categories: {
          for (final category in _allCategories) category.id: category,
        },
        transactionCount: _allTransactions.length,
      ),
    );
  }

  /// The chip is a view filter, not the preference: switching it here shows
  /// another currency's month, it does not change what new records default to.
  ///
  /// Falls through the preferred currency before the first one on record, so
  /// someone who keeps a few euro receipts alongside their lira still opens on
  /// lira.
  Currency _resolveCurrency(List<Currency> available) {
    final selected = _currency;
    if (selected != null && available.contains(selected)) return selected;

    final preferred = _settings.readCurrency();
    if (available.contains(preferred)) return preferred;
    return available.isNotEmpty ? available.first : preferred;
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
