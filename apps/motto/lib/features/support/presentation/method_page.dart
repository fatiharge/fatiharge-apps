import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/support/domain/method_text.dart';

/// What the result is built on, and what it is not.
@RoutePage()
class MethodPage extends StatelessWidget {
  const MethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Yöntem')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            for (final section in methodSections) ...[
              Text(section.heading, style: text.titleMedium),
              const SizedBox(height: 8),
              Text(section.body, style: text.bodyMedium),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}
