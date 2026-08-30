import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:motto/infrastructure/language/app_language.dart';
import 'package:motto/route/app_router.gr.dart';

/// With no account this screen and the ones it links to are the only channel
/// there is. A complaint with no way out goes to the store review, and a
/// one-star review cannot be answered with a fix.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChainCubit>()..unawaitedLoad(),
      child: const _SettingsView(),
    );
  }
}

/// The language, changed here and nowhere else.
///
/// It moves both halves at once: `easy_localization` for the words that ship
/// with the app, and the header every request carries for the words that come
/// down from the server. Changing one and not the other is a screen whose
/// title and paragraph disagree.
Future<void> _pickLanguage(BuildContext context) async {
  final chosen = await showModalBottomSheet<String>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tag in AppLanguage.supported)
            ListTile(
              title: Text('settings.languages.$tag'.tr()),
              trailing: context.locale.languageCode == tag
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.of(sheet).pop(tag),
            ),
        ],
      ),
    ),
  );
  if (chosen == null || !context.mounted) return;

  await getIt<AppLanguage>().choose(chosen);
  if (context.mounted) await context.setLocale(Locale(chosen));
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: SafeArea(
        child: BlocBuilder<ChainCubit, ChainState>(
          builder: (context, state) => ListView(
            children: [
              ListTile(
                title: Text('settings.reminderHour'.tr()),
                subtitle: Text(
                  state.chain.started
                      ? '${state.hour.toString().padLeft(2, '0')}:00'
                      : 'settings.askedLater'.tr(),
                ),
                enabled: state.chain.started,
                onTap: () => _pickHour(context, state.hour),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: getIt<MascotStore>().visible,
                builder: (context, visible, _) => SwitchListTile(
                  title: const Text('Maskot'),
                  subtitle: Text(
                    visible
                        ? 'settings.mascotOn'.tr()
                        : 'settings.mascotOff'.tr(),
                  ),
                  value: visible,
                  onChanged: (value) =>
                      getIt<MascotStore>().setVisible(value: value),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text('settings.language'.tr()),
                subtitle: Text('settings.languageName'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLanguage(context),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text('settings.privacy'.tr()),
                onTap: () => context.router.push(const PrivacyRoute()),
              ),
              ListTile(
                title: Text('settings.faq'.tr()),
                onTap: () => context.router.push(FaqRoute()),
              ),
              ListTile(
                title: Text('settings.method'.tr()),
                onTap: () => context.router.push(const MethodRoute()),
              ),
              ListTile(
                title: Text('settings.feedback'.tr()),
                onTap: () => context.router.push(const FeedbackRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickHour(BuildContext context, int current) async {
    final cubit = context.read<ChainCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
    );
    if (picked == null) return;

    await cubit.setHour(picked.hour);
  }
}
