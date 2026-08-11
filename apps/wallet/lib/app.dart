import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/features/settings/presentation/theme_preference_label.dart';
import 'package:wallet/features/settings/presentation/views/reminder_section.dart';
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
          title: 'Warizo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: router.config(),
          // Rewrites the scheduled window on every launch, and on every
          // language change: a notification's text is written when it is
          // scheduled, so this is the only moment it can follow the app.
          builder: (context, child) =>
              _RescheduleReminder(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Reschedules the monthly reminder whenever the locale changes, launch
/// included.
///
/// A widget rather than a call in `main`: the notification text has to be
/// translated, and only something inside the tree can do that.
class _RescheduleReminder extends StatefulWidget {
  const _RescheduleReminder({required this.child});

  final Widget child;

  @override
  State<_RescheduleReminder> createState() => _RescheduleReminderState();
}

class _RescheduleReminderState extends State<_RescheduleReminder> {
  Locale? _scheduledFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = context.locale;
    if (locale == _scheduledFor) return;
    _scheduledFor = locale;

    unawaited(
      getIt<SummaryReminderController>().refresh(summaryTextOf(context)),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
