import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// What this is built on, in the open. Never behind a paywall: a claim you
/// have to pay to check is not one.
///
/// "Uyarlanmıştır", not "doğrulanmıştır" — items translated for this app are
/// not a validated Turkish instrument.
class BasisSection extends StatelessWidget {
  const BasisSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text('basis.title'.tr(), style: text.titleMedium),
        children: [
          Text(
            'basis.body'.tr(),
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'basis.limits'.tr(),
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
