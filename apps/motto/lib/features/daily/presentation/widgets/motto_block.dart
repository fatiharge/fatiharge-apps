import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.gr.dart';

/// The motto, first on the screen.
///
/// What somebody has; the day below is only what the app suggests about it.
/// The other way round buries the thing they came back for.
class MottoBlock extends StatelessWidget {
  const MottoBlock({required this.motto, super.key});

  final String motto;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.router.push(const MottoDetailRoute()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'motto.label'.tr(),
              style: text.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              motto,
              style: text.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
