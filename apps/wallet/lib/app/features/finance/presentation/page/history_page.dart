import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/app/config/injectable.dart';
import 'package:wallet/app/features/finance/application/history/history_bloc.dart';
import 'package:wallet/app/features/finance/application/history/history_effect.dart';
import 'package:wallet/app/features/finance/application/history/history_event.dart';
import 'package:wallet/app/features/finance/application/history/history_state.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/app/features/finance/presentation/views/history_filter_sheet.dart';
import 'package:wallet/app/features/finance/presentation/views/transaction_tile.dart';
import 'package:wallet/app/route/app_router.gr.dart';

/// The full transaction list, with filtering and swipe-to-delete.
@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HistoryBloc>()..add(const HistoryStarted()),
    child: const _HistoryView(),
  );
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  StreamSubscription<HistoryEffect>? _effects;

  @override
  void initState() {
    super.initState();
    // One-shot effects drive the snackbar; they are not part of state, so a
    // rebuild never re-shows them.
    _effects = context.read<HistoryBloc>().effects.listen(_onEffect);
  }

  @override
  void dispose() {
    unawaited(_effects?.cancel());
    super.dispose();
  }

  void _onEffect(HistoryEffect effect) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();

    switch (effect) {
      case HistoryTransactionRemoved(:final transaction):
        messenger.showSnackBar(
          SnackBar(
            content: Text('history.deleted'.tr()),
            action: SnackBarAction(
              label: 'common.undo'.tr(),
              onPressed: () => context.read<HistoryBloc>().add(
                HistoryDeleteUndone(transaction),
              ),
            ),
          ),
        );
      case HistoryDeleteRestored():
        messenger.showSnackBar(
          SnackBar(content: Text('history.restored'.tr())),
        );
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HistoryBloc, HistoryState>(
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: Text('tabs.history'.tr()),
        actions: [
          IconButton(
            onPressed: () => _openFilter(context, state),
            tooltip: 'history.filter'.tr(),
            icon: Badge(
              isLabelVisible: !state.filter.isEmpty,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: switch (state) {
        HistoryState(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        HistoryState(isFilteredEmpty: true) => EmptyState(
          icon: Icons.search_off,
          title: 'history.no_match'.tr(),
          action: TextButton(
            onPressed: () => context.read<HistoryBloc>().add(
              const HistoryFilterCleared(),
            ),
            child: Text('history.clear_filter'.tr()),
          ),
        ),
        HistoryState(isEmpty: true) => EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'history.empty_title'.tr(),
          message: 'history.empty_message'.tr(),
        ),
        _ => _TransactionList(state: state),
      },
    ),
  );

  Future<void> _openFilter(BuildContext context, HistoryState state) async {
    final bloc = context.read<HistoryBloc>();
    final filter = await showModalBottomSheet<TransactionFilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => HistoryFilterSheet(
        filter: state.filter,
        categories: state.categories.values.toList(),
      ),
    );
    if (filter == null) return;
    bloc.add(HistoryFilterChanged(filter.filter));
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    final items = state.visible;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = items[index];
        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          onDismissed: (_) => context.read<HistoryBloc>().add(
            HistoryTransactionDeleted(transaction),
          ),
          child: TransactionTile(
            transaction: transaction,
            category: state.categories[transaction.categoryId],
            onTap: () => _edit(context, transaction),
          ),
        );
      },
    );
  }

  void _edit(BuildContext context, MoneyTransaction transaction) =>
      context.router.push(TransactionEntryRoute(existing: transaction));
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    color: Theme.of(context).colorScheme.errorContainer,
    child: Icon(
      Icons.delete_outline,
      color: Theme.of(context).colorScheme.onErrorContainer,
    ),
  );
}
