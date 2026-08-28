import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';

/// Every archetype there is, for whoever paid.
///
/// Premium because it is the one thing here that is not about the reader: it
/// is the map, and the map is worth something to somebody who already has
/// their own place on it.
@RoutePage()
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileCubit>()..unawaitedLoad()),
        BlocProvider(create: (_) => getIt<DailyCubit>()..unawaitedLoad()),
      ],
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
                    BlocBuilder<DailyCubit, DailyState>(
                      builder: (context, daily) => Text(
                        '${daily.archetypes.length} arketip',
                        style: text.headlineSmall,
                      ),
                    ),
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

            // From the package, not from the history: the history holds the
            // ones this device was given, and a gallery of what you already
            // have is not a gallery.
            final had = {
              for (final result in state.results) result.archetype.id,
            };

            return BlocBuilder<DailyCubit, DailyState>(
              builder: (context, daily) => ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  for (final archetype in daily.archetypes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  archetype.name,
                                  style: text.titleMedium,
                                ),
                              ),
                              if (had.contains(archetype.id))
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(archetype.summary, style: text.bodyMedium),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
