import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/application/history/history_effect.dart';
import 'package:wallet/features/finance/application/history/history_event.dart';
import 'package:wallet/features/finance/application/history/history_state.dart';
import 'package:wallet/features/finance/presentation/views/history_filter_sheet.dart';
import 'package:wallet/features/finance/presentation/views/history_view.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/route/app_router.gr.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HistoryBloc>()..add(const HistoryStarted()),
    child: const _HistoryScaffold(),
  );
}

/// Everything the list cannot do for itself: the effect subscription, the
/// filter sheet, and navigation to the entry form.
class _HistoryScaffold extends StatefulWidget {
  const _HistoryScaffold();

  @override
  State<_HistoryScaffold> createState() => _HistoryScaffoldState();
}

class _HistoryScaffoldState extends State<_HistoryScaffold> {
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
            content: Text(context.tr(LocaleKeys.history_deleted)),
            action: SnackBarAction(
              label: context.tr(LocaleKeys.common_undo),
              onPressed: () => context.read<HistoryBloc>().add(
                HistoryDeleteUndone(transaction),
              ),
            ),
          ),
        );
      case HistoryDeleteRestored():
        messenger.showSnackBar(
          SnackBar(content: Text(context.tr(LocaleKeys.history_restored))),
        );
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HistoryBloc, HistoryState>(
    builder: (context, state) {
      final bloc = context.read<HistoryBloc>();
      return Scaffold(
        appBar: AppBar(
          title: Text(context.tr(LocaleKeys.tabs_history)),
          actions: [
            IconButton(
              onPressed: () => _openFilter(context, state),
              tooltip: context.tr(LocaleKeys.history_filter),
              icon: Badge(
                isLabelVisible: !state.filter.isEmpty,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : HistoryView(
                transactions: state.visible,
                categories: state.categories,
                isFiltered: state.isFilteredEmpty,
                onDelete: (transaction) =>
                    bloc.add(HistoryTransactionDeleted(transaction)),
                onEdit: (transaction) => context.router.push(
                  TransactionEntryRoute(existing: transaction),
                ),
                onClearFilter: () => bloc.add(const HistoryFilterCleared()),
              ),
      );
    },
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
