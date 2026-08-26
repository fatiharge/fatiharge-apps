import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_bloc.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_effect.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_event.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/features/finance/presentation/views/dashboard_view.dart';
import 'package:wallet/features/finance/presentation/views/reminder_nudge.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/route/app_router.gr.dart';

/// Monthly totals, the category breakdown and any blown budgets.
///
/// Wiring only: provides the bloc, resolves the union, and turns the state
/// into arguments for [DashboardView]. Everything drawn lives in the view.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DashboardBloc>()..add(const DashboardStarted()),
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.tr(LocaleKeys.tabs_dashboard)),
        // The dashboard is the app's landing tab, so its action bar is the one
        // place settings are reliably found without adding a fourth
        // navigation destination for them.
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.tr(LocaleKeys.settings_title),
          ),
        ],
      ),
      body: const _DashboardBody(),
    ),
  );
}

/// The state-driven half, plus the one-shot effect subscription.
class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  StreamSubscription<DashboardEffect>? _effects;

  @override
  void initState() {
    super.initState();
    // One-shot effects drive the review ask; it is not part of state, so a
    // rebuild never re-fires it.
    _effects = context.read<DashboardBloc>().effects.listen(_onEffect);
  }

  @override
  void dispose() {
    unawaited(_effects?.cancel());
    super.dispose();
  }

  void _onEffect(DashboardEffect effect) {
    switch (effect) {
      case DashboardReviewMomentReached():
        unawaited(getIt<ReviewPrompt>().ask());
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final bloc = context.read<DashboardBloc>();
          return switch (state) {
            DashboardLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DashboardReady() => DashboardView(
              reminderNudge: _reminderNudge(state),
              period: state.period,
              currency: state.currency,
              availableCurrencies: state.availableCurrencies,
              summary: state.summary,
              budgetStatuses: state.budgetStatuses,
              categories: state.categories,
              onPreviousMonth: () =>
                  bloc.add(const DashboardPreviousMonthRequested()),
              onNextMonth: state.canShowNextMonth
                  ? () => bloc.add(const DashboardNextMonthRequested())
                  : null,
              onCurrencySelected: (currency) =>
                  bloc.add(DashboardCurrencySelected(currency)),
              onAddTransaction: () =>
                  context.router.push(TransactionEntryRoute()),
            ),
          };
        },
      );

  /// The offer, or nothing.
  ///
  /// Withheld unless the month has numbers in it: "shall we remind you when
  /// the summary is ready" only means something to someone who has just been
  /// shown one. It also stops after a few showings and after being closed —
  /// see [ReminderNudge.maxShowings].
  Widget? _reminderNudge(DashboardReady state) {
    final settings = getIt<SettingsRepository>();

    if (state.summary.isEmpty) return null;
    if (settings.readSummaryReminder().enabled) return null;
    if (settings.isSummaryNudgeDismissed()) return null;
    if (settings.summaryNudgeCount() >= ReminderNudge.maxShowings) return null;

    return _CountedNudge(settings: settings);
  }
}

/// Records the showing once, when it is first built, rather than on every
/// rebuild — a scroll or a theme change is not another offer.
class _CountedNudge extends StatefulWidget {
  const _CountedNudge({required this.settings});

  final SettingsRepository settings;

  @override
  State<_CountedNudge> createState() => _CountedNudgeState();
}

class _CountedNudgeState extends State<_CountedNudge> {
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.settings.recordSummaryNudge());
  }

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();

    return ReminderNudge(
      onAccept: () async {
        setState(() => _closed = true);
        await context.router.push(const SettingsRoute());
      },
      onDismiss: () async {
        setState(() => _closed = true);
        await widget.settings.dismissSummaryNudge();
      },
    );
  }
}
