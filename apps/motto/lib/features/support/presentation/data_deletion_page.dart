import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/data_deletion.dart';
import 'package:motto/features/support/domain/deletion_text.dart';

/// What survives is said before the button, not after: the usage counter stays
/// and finding that out afterwards is how a deletion screen becomes a one-star
/// review.
@RoutePage()
class DataDeletionPage extends StatefulWidget {
  const DataDeletionPage({super.key});

  @override
  State<DataDeletionPage> createState() => _DataDeletionPageState();
}

class _DataDeletionPageState extends State<DataDeletionPage> {
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
      appBar: AppBar(title: const Text('Verilerimi sil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            if (_done) ...[
              Text('Silindi.', style: text.titleMedium),
              const SizedBox(height: 12),
              Text(deletionCounterReason, style: text.bodyMedium),
            ] else ...[
              Text('Silinecekler', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final item in deletionGoes)
                Text('• $item', style: text.bodyMedium),
              const SizedBox(height: 8),
              Text(deletionAnswersNote, style: text.bodyMedium),
              const SizedBox(height: 24),
              Text('Kalacaklar', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final item in deletionStays)
                Text('• $item', style: text.bodyMedium),
              const SizedBox(height: 12),
              Text(
                deletionCounterReason,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (_failed) ...[
                Text(
                  'Silinemedi. Bağlantını kontrol edip tekrar dene.',
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
                child: Text(_deleting ? 'Siliniyor…' : 'Verilerimi sil'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
