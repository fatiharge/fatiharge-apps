import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/features/settings/presentation/theme_preference_label.dart';
import 'package:wallet/features/settings/presentation/views/setting_option_tile.dart';

/// Needs a [SettingsCubit] above it — the same one `MaterialApp.themeMode`
/// watches, so the choice takes effect as it is made.
class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsCubit, ThemePreference>(
        builder: (context, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final preference in ThemePreference.values)
              SettingOptionTile(
                icon: preference.icon,
                label: preference.label(context),
                selected: preference == selected,
                onTap: () =>
                    context.read<SettingsCubit>().selectTheme(preference),
              ),
          ],
        ),
      );
}
