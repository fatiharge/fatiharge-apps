import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
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

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: BlocBuilder<ChainCubit, ChainState>(
          builder: (context, state) => ListView(
            children: [
              ListTile(
                title: const Text('Hatırlatma saati'),
                subtitle: Text(
                  state.chain.started
                      ? '${state.hour.toString().padLeft(2, '0')}:00'
                      : 'Zincir başlayınca sorulur',
                ),
                enabled: state.chain.started,
                onTap: () => _pickHour(context, state.hour),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: getIt<MascotStore>().visible,
                builder: (context, visible, _) => SwitchListTile(
                  title: const Text('Maskot'),
                  subtitle: Text(
                    visible ? 'Ekranda dolaşıyor' : 'Kapalı',
                  ),
                  value: visible,
                  onChanged: (value) =>
                      getIt<MascotStore>().setVisible(value: value),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Gizlilik ve izinler'),
                onTap: () => context.router.push(const PrivacyRoute()),
              ),
              ListTile(
                title: const Text('Sık sorulanlar'),
                onTap: () => context.router.push(FaqRoute()),
              ),
              ListTile(
                title: const Text('Yöntem'),
                onTap: () => context.router.push(const MethodRoute()),
              ),
              ListTile(
                title: const Text('Geri bildirim'),
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
