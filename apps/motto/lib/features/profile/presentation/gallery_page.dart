import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';

/// All eight, for whoever paid.
///
/// Premium because it is the one thing here that is not about the reader: it
/// is the map, and the map is worth something to somebody who already has
/// their own place on it.
@RoutePage()
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..unawaitedLoad(),
      child: const _GalleryView(),
    );
  }
}

class _GalleryView extends StatelessWidget {
  const _GalleryView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Arketipler')),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (!state.premium) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sekiz arketip', style: text.headlineSmall),
                    const SizedBox(height: 12),
                    Text(
                      'Hepsini okumak premium. Kendi arketibin her zaman açık.',
                      style: text.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // TODO(fcetin): open the paywall — T13.
                    FilledButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Satın alma yakında.'),
                            ),
                          ),
                      child: const Text('Kilidi aç'),
                    ),
                  ],
                ),
              );
            }

            // TODO(fcetin): read all eight from the content package — the
            // history only carries the ones this device has been given.
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                for (final result in state.results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.archetype.name, style: text.titleMedium),
                        const SizedBox(height: 6),
                        Text(result.archetype.summary, style: text.bodyMedium),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
