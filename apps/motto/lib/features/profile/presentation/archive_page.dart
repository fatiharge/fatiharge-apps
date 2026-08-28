import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// Every result, newest first. Free: it is a record of what someone did, not
/// a feature sold back to them.
@RoutePage()
class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..unawaitedLoad(),
      child: const _ArchiveView(),
    );
  }
}

class _ArchiveView extends StatelessWidget {
  const _ArchiveView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.results.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Burada henüz bir şey yok.',
                    style: text.bodyLarge,
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: state.results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final result = state.results[index];
                final at = result.claimedAt.toLocal();

                return ListTile(
                  title: Text(result.archetype.name),
                  subtitle: Text('${at.day}.${at.month}.${at.year}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.router.push(
                    ResultRoute(
                      archetype: result.archetype,
                      resultId: result.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
