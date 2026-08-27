import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// The tab the real profile will fill, so the bar has its shape from the start.
// TODO(fcetin): archive, reports and plan — T26.
@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yakında', style: text.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'Geçmiş sonuçların, raporların ve planın burada olacak.',
                style: text.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
