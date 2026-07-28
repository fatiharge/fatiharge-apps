import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/features/finance/presentation/views/dashboard_view.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/route/app_router.gr.dart';

/// Monthly totals, the category breakdown and any blown budgets.
///
/// Wiring only: provides the cubit, resolves the union, and turns the state
/// into arguments for [DashboardView]. Everything drawn lives in the view.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DashboardCubit>()..start(),
    child: Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.tabs_dashboard.tr()),
        // The dashboard is the app's landing tab, so its action bar is the one
        // place settings are reliably found without adding a fourth
        // navigation destination for them.
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings_outlined),
            tooltip: LocaleKeys.settings_title.tr(),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final cubit = context.read<DashboardCubit>();
          return switch (state) {
            DashboardLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DashboardReady() => DashboardView(
              period: state.period,
              currency: state.currency,
              availableCurrencies: state.availableCurrencies,
              summary: state.summary,
              budgetStatuses: state.budgetStatuses,
              categories: state.categories,
              onPreviousMonth: cubit.showPreviousMonth,
              onNextMonth: state.canShowNextMonth ? cubit.showNextMonth : null,
              onCurrencySelected: cubit.selectCurrency,
              onAddTransaction: () =>
                  context.router.push(TransactionEntryRoute()),
            ),
          };
        },
      ),
    ),
  );
}
