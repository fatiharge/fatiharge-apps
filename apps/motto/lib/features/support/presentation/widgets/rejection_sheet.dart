import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/feedback_cubit.dart';

/// Which archetype gets rejected, and in which direction, is the only
/// correction signal the mapping table has — and asking someone who just said
/// "this is not me" to write an essay returns nothing at all.
const rejectionReasons = [
  'Tam tersi gibi',
  'Yakın ama tam değil',
  'Hiç tanımadım',
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
                const SnackBar(content: Text('Not aldık, teşekkürler.')),
              );
            },
          ),
        const SizedBox(height: 8),
      ],
    ),
  ),
);
