import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/support_copy_cubit.dart';

/// The questions, answered before they are asked.
@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({@QueryParam('item') this.openItem, super.key});

  /// Lets another screen link straight to one entry rather than to a list
  /// somebody then has to search.
  final String? openItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportCopyCubit>()..unawaitedLoad(),
      child: _FaqView(openItem: openItem),
    );
  }
}

class _FaqView extends StatelessWidget {
  const _FaqView({this.openItem});

  final String? openItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sık sorulanlar')),
      body: SafeArea(
        child: BlocBuilder<SupportCopyCubit, SupportCopyState>(
          builder: (context, state) {
            if (state.status == SupportCopyStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.copy == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sorular yüklenemedi. Bağlantını kontrol edip tekrar dene.',
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final item in state.copy!.faq)
                  ExpansionTile(
                    key: PageStorageKey(item.id),
                    initiallyExpanded: item.id == openItem,
                    title: Text(item.question),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.answer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
