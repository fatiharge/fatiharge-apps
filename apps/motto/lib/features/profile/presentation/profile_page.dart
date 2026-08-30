import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/features/game/application/turns_cubit.dart';
import 'package:motto/features/game/presentation/open_game.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/features/support/presentation/widgets/could_not_load.dart';
import 'package:motto/features/support/presentation/widgets/settings_button.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: const [SettingsButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.failed) {
              // The other two tabs already offer this. Without it, a token
              // that died while the phone was in a pocket left this screen a
              // dead end: nothing to press, and nothing that would ask again
              // short of killing the app.
              return CouldNotLoad(
                said: 'profile.failed'.tr(),
                retry: context.read<ProfileCubit>().load,
              );
            }

            final current = state.current;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
              children: [
                // The archetype is the first thing Bugün says, in the card
                // and in the row under it. Saying it twice made this screen
                // look like a copy of that one rather than a place of its own.
                if (current == null) ...[
                  Text(
                    'profile.noInventory'.tr(),
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('profile.past'.tr()),
                  subtitle: Text(
                    'profile.records'.plural(state.results.length),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.router.push(const ArchiveRoute()),
                ),
                // Here whenever there is a turn to spend, which is the only
                // state in which it leads anywhere. Somebody who switched the
                // mascot off has no other way in.
                if (context.watch<TurnsCubit>().state.any)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('profile.game'.tr()),
                    subtitle: Text(
                      'profile.gameNote'.tr(),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: openGame,
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Arketipler'),
                  subtitle: Text(
                    state.premium ? 'profile.gallery'.tr() : 'Premium',
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
