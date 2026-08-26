import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:utility_kit/utility_kit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_effect.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_event.dart';
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
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

/// An [EffectBloc] because the review ask is a moment, and a moment kept in
/// state would be asked for again on every rebuild.
@injectable
class DashboardBloc
    extends EffectBloc<DashboardEvent, DashboardState, DashboardEffect> {
  DashboardBloc(
    this._transactions,
    this._categories,
    this._budgets,
    this._settings,
    this._review, {
    @ignoreParam this.clock = systemClock,
  }) : super(const DashboardLoading()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardDataReceived>(_onDataReceived);
    on<DashboardPreviousMonthRequested>(_onPreviousMonth);
    on<DashboardNextMonthRequested>(_onNextMonth);
    on<DashboardCurrencySelected>(_onCurrencySelected);
  }

  final TransactionRepository _transactions;
  final CategoryRepository _categories;
  final BudgetRepository _budgets;
  final SettingsRepository _settings;
  final ReviewPrompt _review;

  final Clock clock;

  final List<StreamSubscription<void>> _subscriptions = [];

  List<MoneyTransaction> _allTransactions = const [];
  List<Category> _allCategories = const [];
  List<Budget> _allBudgets = const [];

  late MonthPeriod _period = MonthPeriod.of(clock());
  Currency? _currency;
  bool _hasTransactions = false;
  bool _reviewAnnounced = false;

  void _onStarted(DashboardStarted event, Emitter<DashboardState> emit) {
    if (_subscriptions.isNotEmpty) return;

    _subscriptions.addAll([
      _transactions.watchAll().listen(
        (items) => add(DashboardDataReceived(transactions: items)),
      ),
      _categories.watchAll().listen(
        (items) => add(DashboardDataReceived(categories: items)),
      ),
      _budgets.watchAll().listen(
        (items) => add(DashboardDataReceived(budgets: items)),
      ),
    ]);
  }

  void _onDataReceived(
    DashboardDataReceived event,
    Emitter<DashboardState> emit,
  ) {
    final transactions = event.transactions;
    if (transactions != null) {
      _allTransactions = transactions;
      _hasTransactions = true;
    }

    final categories = event.categories;
    if (categories != null) _allCategories = categories;

    final budgets = event.budgets;
    if (budgets != null) _allBudgets = budgets;

    _emitReady(emit);
  }

  void _onPreviousMonth(
    DashboardPreviousMonthRequested event,
    Emitter<DashboardState> emit,
  ) {
    _period = _period.previous;
    _emitReady(emit);
  }

  void _onNextMonth(
    DashboardNextMonthRequested event,
    Emitter<DashboardState> emit,
  ) {
    if (!_canShowNextMonth) return;

    _period = _period.next;
    _emitReady(emit);
  }

  void _onCurrencySelected(
    DashboardCurrencySelected event,
    Emitter<DashboardState> emit,
  ) {
    _currency = event.currency;
    _emitReady(emit);
  }

  bool get _canShowNextMonth => _period.isBefore(MonthPeriod.of(clock()));

  void _emitReady(Emitter<DashboardState> emit) {
    // Otherwise the screen flashes an empty month before storage answers.
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
      ),
    );

    _announceReviewMoment(summary);
  }

  /// Once per screen: [_emitReady] runs on every repository change, and the
  /// ask is not recorded until whoever takes the effect has acted on it.
  void _announceReviewMoment(MonthlySummary summary) {
    if (_reviewAnnounced) return;

    final moment = _review.isMoment(
      transactionCount: _allTransactions.length,
      viewingMonthWithData: !summary.isEmpty,
    );
    if (!moment) return;

    _reviewAnnounced = true;
    emitEffect(const DashboardReviewMomentReached());
  }

  /// Preferred currency before first-on-record, so a few euro receipts do not
  /// take over a lira account.
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
