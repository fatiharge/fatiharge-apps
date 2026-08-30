import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/feedback_cubit.dart';

/// The email field is optional and stays optional: making it required
/// collapses the submission rate, and a complaint with nowhere to go goes to
/// the store review instead.
@RoutePage()
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedbackCubit>(),
      child: const _FeedbackView(),
    );
  }
}

Map<api.FeedbackKind, String> _kinds = {
  api.FeedbackKind.BUG: 'feedback.broken'.tr(),
  api.FeedbackKind.SUGGESTION: 'feedback.idea'.tr(),
  api.FeedbackKind.CONTENT: 'feedback.words'.tr(),
  api.FeedbackKind.OTHER: 'feedback.other'.tr(),
};

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final _message = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('feedback.title'.tr())),
      body: SafeArea(
        child: BlocBuilder<FeedbackCubit, FeedbackState>(
          builder: (context, state) {
            if (state.status == FeedbackStatus.sent) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('feedback.sent'.tr(), style: text.titleMedium),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final entry in _kinds.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: state.kind == entry.key,
                        onSelected: (_) =>
                            context.read<FeedbackCubit>().chooseKind(entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _message,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'feedback.what'.tr(),
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'feedback.email'.tr(),
                    helperText: 'feedback.emailNote'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'feedback.attached'.tr(),
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (state.status == FeedbackStatus.failed) ...[
                  Text(
                    'feedback.failed'.tr(),
                    style: text.bodyMedium?.copyWith(color: scheme.error),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: state.status == FeedbackStatus.sending
                      ? null
                      : () => context.read<FeedbackCubit>().send(
                          message: _message.text,
                          email: _email.text,
                        ),
                  child: Text(
                    state.status == FeedbackStatus.sending
                        ? 'feedback.sending'.tr()
                        : 'feedback.send'.tr(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
