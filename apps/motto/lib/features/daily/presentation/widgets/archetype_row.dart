import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/daily/application/daily_state.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/route/app_router.gr.dart';

/// Who somebody is, one row, opening the result — and through it the paid
/// report.
///
/// From the server when it answers, from the package and what this device
/// remembers when it does not: the door to the paid thing should not close
/// because the train went into a tunnel.
class ArchetypeRow extends StatelessWidget {
  const ArchetypeRow._({
    required this.archetype,
    required this.resultId,
  });

  /// Null when neither source knows who this is yet.
  static Widget? forState(ProfileState profile, DailyState daily) {
    if (profile.current case final api.ResultSummary result) {
      return ArchetypeRow._(archetype: result.archetype, resultId: result.id);
    }
    if (daily.mine case final PackArchetype mine) {
      if (daily.resultId case final int id) {
        return ArchetypeRow._(archetype: mine.asResponse, resultId: id);
      }
    }
    return null;
  }

  final api.ArchetypeResponse archetype;
  final int resultId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.router.push(
        ResultRoute(archetype: archetype, resultId: resultId),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARKETİPİN',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(archetype.name, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Raporun ve derin raporun burada.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

extension on PackArchetype {
  api.ArchetypeResponse get asResponse => api.ArchetypeResponse(
    id: id,
    name: name,
    summary: summary,
    motto: motto,
    confident: true,
  );
}
