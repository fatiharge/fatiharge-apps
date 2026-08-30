import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/data_deletion.dart';
import 'package:motto/features/support/application/support_copy_cubit.dart';

/// The confirmation, which is the whole screen.
///
/// What survives is said before the button: the usage counter stays, and
/// finding that out afterwards is how a deletion screen becomes a review.
@RoutePage()
class DataDeletionPage extends StatelessWidget {
  const DataDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportCopyCubit>()..unawaitedLoad(),
      child: const _DataDeletionView(),
    );
  }
}

class _DataDeletionView extends StatefulWidget {
  const _DataDeletionView();

  @override
  State<_DataDeletionView> createState() => _DataDeletionViewState();
}

class _DataDeletionViewState extends State<_DataDeletionView> {
  bool _deleting = false;
  bool _done = false;
  bool _failed = false;

  Future<void> _delete() async {
    setState(() {
      _deleting = true;
      _failed = false;
    });
    try {
      await getIt<DataDeletion>().deleteEverything();
      if (mounted) setState(() => _done = true);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('deletion.title'.tr())),
      body: SafeArea(
        child: BlocBuilder<SupportCopyCubit, SupportCopyState>(
          builder: (context, state) {
            final copy = state.copy?.deletion;
            if (copy == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.status == SupportCopyStatus.failed
                        ? 'deletion.copyFailed'.tr()
                        : '…',
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                if (_done) ...[
                  Text('Silindi.', style: text.titleMedium),
                  const SizedBox(height: 12),
                  Text(copy.counterReason, style: text.bodyMedium),
                ] else ...[
                  Text('Silinecekler', style: text.titleMedium),
                  const SizedBox(height: 8),
                  for (final item in copy.goes)
                    Text('• $item', style: text.bodyMedium),
                  const SizedBox(height: 8),
                  Text(copy.answersNote, style: text.bodyMedium),
                  const SizedBox(height: 24),
                  Text('Kalacaklar', style: text.titleMedium),
                  const SizedBox(height: 8),
                  for (final item in copy.stays)
                    Text('• $item', style: text.bodyMedium),
                  const SizedBox(height: 12),
                  Text(
                    copy.counterReason,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_failed) ...[
                    Text(
                      'deletion.failed'.tr(),
                      style: text.bodyMedium?.copyWith(color: scheme.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                    onPressed: _deleting ? null : _delete,
                    child: Text(
                      _deleting
                          ? 'deletion.deleting'.tr()
                          : 'deletion.title'.tr(),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
