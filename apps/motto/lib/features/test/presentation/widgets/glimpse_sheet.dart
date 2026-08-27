import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';

/// A sheet rather than a screen, so dismissing it returns to the next question
/// instead of navigating back into the flow. Costs no use: its whole job is to
/// make finishing feel worth it.
class GlimpseSheet extends StatelessWidget {
  const GlimpseSheet({
    required this.archetype,
    required this.onContinue,
    super.key,
  });

  final api.ArchetypeResponse archetype;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Şimdilik böyle görünüyorsun',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(archetype.name, style: text.headlineMedium),
          const SizedBox(height: 16),
          Text(archetype.summary, style: text.bodyLarge),
          const SizedBox(height: 24),
          // Said plainly, because it is true and because it is the reason to
          // keep going.
          Text(
            'Kalan sorular bunu değiştirebilir.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onContinue, child: const Text('Devam et')),
        ],
      ),
    );
  }
}
