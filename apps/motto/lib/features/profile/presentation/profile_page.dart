import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.failed) {
              return const Center(child: Text('Profil yüklenemedi.'));
            }

            final current = state.current;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
              children: [
                if (current == null)
                  Text(
                    'Henüz bir envanter doldurmadın.',
                    style: text.bodyLarge,
                  )
                else ...[
                  Text(
                    'ŞU ANKİ ARKETİPİN',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(current.archetype.name, style: text.headlineSmall),
                  const SizedBox(height: 12),
                  Text(current.archetype.summary, style: text.bodyLarge),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.router.push(
                      ResultRoute(
                        archetype: current.archetype,
                        resultId: current.id,
                      ),
                    ),
                    child: const Text('Sonucunu gör'),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Geçmiş sonuçların'),
                  subtitle: Text('${state.results.length} kayıt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.router.push(const ArchiveRoute()),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ayarlar'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.router.push(const SettingsRoute()),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Arketipler'),
                  subtitle: Text(
                    state.premium ? 'Sekizini de gez' : 'Premium',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.router.push(const GalleryRoute()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
