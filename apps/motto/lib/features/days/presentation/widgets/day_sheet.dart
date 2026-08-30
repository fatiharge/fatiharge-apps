import 'package:flutter/material.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_assembler.dart';

/// What a day said, opened from the box that day filled.
///
/// The whole reason the grid is worth having: the chain answers "how much did
/// I keep up", and a day in it answers "what was I told" — one is the way into
/// the other. The words are already on the phone; the position in the run is
/// all that was needed to find them again.
Future<void> showDaySheet(
  BuildContext context, {
  required ContentPack pack,
  required String archetypeId,
  required int place,
}) {
  final content = DailyAssembler.assemble(
    pack: pack,
    archetypeId: archetypeId,
    daysMarked: place,
  );

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) {
      final text = Theme.of(sheet).textTheme;
      final scheme = Theme.of(sheet).colorScheme;

      if (content == null) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Text(
              'O günün metni elimde yok.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${content.day}. GÜN',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(content.title, style: text.titleLarge),
                const SizedBox(height: 12),
                Text(content.body, style: text.bodyLarge),
                const SizedBox(height: 12),
                Text(content.connector, style: text.bodyLarge),
                const SizedBox(height: 4),
                Text(content.fragment, style: text.bodyLarge),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(content.action, style: text.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
