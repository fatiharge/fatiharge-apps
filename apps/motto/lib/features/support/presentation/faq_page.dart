import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/support/domain/faq.dart';

/// The questions, answered before they are asked.
///
/// Nothing here touches the network. The moment someone wonders where their
/// data went is the moment they are least likely to have a connection or the
/// patience to wait for one.
@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({@QueryParam('item') this.openItem, super.key});

  /// Lets another screen link straight to one entry rather than to a list
  /// someone then has to search.
  final String? openItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sık sorulanlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final item in faq)
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
        ),
      ),
    );
  }
}
