import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.gr.dart';

/// Fourteen days finished, said above everything else.
class PeriodDoneBanner extends StatelessWidget {
  const PeriodDoneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.router.push(const PeriodDoneRoute()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On dört gün bitti.',
                    style: text.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Raporunu oku, sonra devam et.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}
