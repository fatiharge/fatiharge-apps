import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// A placeholder with the right content and none of the design.
///
/// The result screen and the card people share are one piece of work, and doing
/// half of it now would mean throwing that half away. What this proves today is
/// that the flow reaches an archetype.
@RoutePage()
class ResultPage extends StatelessWidget {
  const ResultPage({required this.result, super.key});

  final api.ResultResponse result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final archetype = result.archetype;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(archetype.name, style: text.displaySmall),
              const SizedBox(height: 16),
              Text(archetype.summary, style: text.bodyLarge),
              const SizedBox(height: 32),
              Text('"${archetype.motto}"', style: text.titleLarge),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
