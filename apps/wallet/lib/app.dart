import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/features/settings/presentation/theme_preference_label.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/theme/app_theme.dart';

/// The root widget: theme, localization and the router.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolved from get_it rather than constructed here: the bootstrap adapter
    // navigates through the same instance once startup finishes.
    final router = getIt<RouteManager>();

    // Above MaterialApp, because `themeMode` is one of its arguments — and the
    // settings page reads this same instance rather than making its own.
    return BlocProvider(
      create: (_) => SettingsCubit(getIt<SettingsRepository>()),
      child: BlocBuilder<SettingsCubit, ThemePreference>(
        builder: (context, theme) => MaterialApp.router(
          title: 'Wariden',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: router.config(),
        ),
      ),
    );
  }
}
