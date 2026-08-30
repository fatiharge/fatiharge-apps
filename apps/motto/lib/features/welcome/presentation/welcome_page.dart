import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.gr.dart';

/// A placeholder with the shape of the real one: this is where the mascot
/// introduces itself, "Başla" sits, and the invite code line will go — never
/// in the middle of the test, where it would interrupt the funnel.
@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // No title: this screen is the app's front door and a bar with a name
        // on it would make it look like a page inside something.
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Motto', style: text.displaySmall),
              const SizedBox(height: 12),
              Text(
                'welcome.line'.tr(),
                style: text.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.router.push(const QuestionRoute()),
                child: Text('welcome.start'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
