import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/feedback_cubit.dart';

/// Which archetype gets rejected, and in which direction, is the only
/// correction signal the mapping table has — and asking someone who just said
/// "this is not me" to write an essay returns nothing at all.
///
/// Read rather than held: a `const` list is built once, and once is before
/// anybody has said which language they read in.
List<String> get rejectionReasons => [
  'rejection.opposite'.tr(),
  'rejection.close'.tr(),
  'rejection.nothing'.tr(),
];

Future<void> showRejectionSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  builder: (sheetContext) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Hangisi?',
            style: Theme.of(sheetContext).textTheme.titleMedium,
          ),
        ),
        for (final reason in rejectionReasons)
          ListTile(
            title: Text(reason),
            onTap: () {
              // Fire and forget: the answer is worth having, but making
              // someone wait for a spinner to say "this is not me" is a way of
              // arguing with them.
              unawaited(getIt<FeedbackCubit>().rejectArchetype(reason));
              Navigator.of(sheetContext).pop();
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(content: Text('rejection.thanks'.tr())),
              );
            },
          ),
        const SizedBox(height: 8),
      ],
    ),
  ),
);
