import 'dart:async';

import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/settings/domain/monthly_summary_reminder.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Shared stream/CRUD behaviour for the fakes below.
///
/// These exist instead of mocks because the cubits' whole contract is "react
/// to the stream" — a mock that returns a fixed list would not exercise it.
class _Collection<T> {
  _Collection(this._idOf);

  final String Function(T item) _idOf;
  final Map<String, T> _items = {};
  final StreamController<List<T>> _controller =
      StreamController<List<T>>.broadcast();

  List<T> get items => _items.values.toList();

  Stream<List<T>> watchAll() async* {
    yield items;
    yield* _controller.stream;
  }

  Future<void> save(T item) async {
    _items[_idOf(item)] = item;
    _controller.add(items);
  }

  Future<void> delete(String id) async {
    _items.remove(id);
    _controller.add(items);
  }

  /// Seeds without emitting — for arranging state before a cubit starts.
  void seed(Iterable<T> items) {
    for (final item in items) {
      _items[_idOf(item)] = item;
    }
  }

  Future<void> dispose() => _controller.close();
}

class FakeTransactionRepository implements TransactionRepository {
  final _Collection<MoneyTransaction> _collection = _Collection(
    (item) => item.id,
  );

  void seed(Iterable<MoneyTransaction> items) => _collection.seed(items);

  Future<void> dispose() => _collection.dispose();

  @override
  Stream<List<MoneyTransaction>> watchAll() => _collection.watchAll();

  @override
  Future<List<MoneyTransaction>> fetchAll() async => _collection.items;

  @override
  Future<void> save(MoneyTransaction transaction) =>
      _collection.save(transaction);

  @override
  Future<void> delete(String id) => _collection.delete(id);
}

class FakeCategoryRepository implements CategoryRepository {
  final _Collection<Category> _collection = _Collection((item) => item.id);

  void seed(Iterable<Category> items) => _collection.seed(items);

  Future<void> dispose() => _collection.dispose();

  @override
  Stream<List<Category>> watchAll() => _collection.watchAll();

  @override
  Future<List<Category>> fetchAll() async => _collection.items;

  @override
  Future<void> save(Category category) => _collection.save(category);

  @override
  Future<void> archive(String id) => _setArchived(id, archived: true);

  @override
  Future<void> restore(String id) => _setArchived(id, archived: false);

  Future<void> _setArchived(String id, {required bool archived}) async {
    final existing = _collection.items.where((c) => c.id == id).firstOrNull;
    if (existing == null) return;
    await _collection.save(existing.copyWith(archived: archived));
  }
}

class FakeBudgetRepository implements BudgetRepository {
  final _Collection<Budget> _collection = _Collection((item) => item.id);

  void seed(Iterable<Budget> items) => _collection.seed(items);

  Future<void> dispose() => _collection.dispose();

  @override
  Stream<List<Budget>> watchAll() => _collection.watchAll();

  @override
  Future<List<Budget>> fetchAll() async => _collection.items;

  @override
  Future<void> save(Budget budget) => _collection.save(budget);

  @override
  Future<void> delete(String id) => _collection.delete(id);
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.theme = ThemePreference.system,
    this.currency = Currency.turkishLira,
    this.onboarded = true,
  });

  ThemePreference theme;
  Currency currency;

  /// Defaults to done: a test that is not about the first-run flow should not
  /// have to opt out of it.
  bool onboarded;

  @override
  ThemePreference readTheme() => theme;

  @override
  Future<void> writeTheme(ThemePreference preference) async =>
      theme = preference;

  @override
  Currency readCurrency() => currency;

  @override
  Future<void> writeCurrency(Currency value) async => currency = value;

  @override
  bool isOnboarded() => onboarded;

  @override
  Future<void> completeOnboarding() async => onboarded = true;

  MonthlySummaryReminder reminder = MonthlySummaryReminder.off;
  bool notificationPromptShown = false;
  int nudges = 0;
  bool nudgeDismissed = false;

  @override
  MonthlySummaryReminder readSummaryReminder() => reminder;

  @override
  Future<void> writeSummaryReminder(MonthlySummaryReminder value) async =>
      reminder = value;

  @override
  bool wasNotificationPromptShown() => notificationPromptShown;

  @override
  Future<void> markNotificationPromptShown() async =>
      notificationPromptShown = true;

  @override
  int summaryNudgeCount() => nudges;

  @override
  Future<void> recordSummaryNudge() async => nudges++;

  @override
  bool isSummaryNudgeDismissed() => nudgeDismissed;

  @override
  Future<void> dismissSummaryNudge() async => nudgeDismissed = true;
}

/// Records what the app asked the platform for, so the permission dance can be
/// tested without one.
class FakeSummaryNotifier implements SummaryNotifier {
  FakeSummaryNotifier({this.permitted = false, this.grantOnRequest = true});

  bool permitted;

  /// What the platform prompt will answer.
  bool grantOnRequest;

  int promptCount = 0;
  int? scheduledDay;
  String? scheduledBody;
  int cancelCount = 0;
  int settingsOpened = 0;

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<bool> requestPermission() async {
    promptCount++;
    return permitted = grantOnRequest;
  }

  @override
  Future<void> schedule({
    required int day,
    required String title,
    required String body,
    required String channelName,
  }) async {
    scheduledDay = day;
    scheduledBody = body;
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
    scheduledDay = null;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}
