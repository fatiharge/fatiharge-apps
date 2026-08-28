import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/test/application/test_cubit.dart';
import 'package:motto/features/test/application/test_state.dart';
import 'package:motto/route/app_router.gr.dart';

/// The pause between the last answer and the result.
///
/// The work behind it takes a moment; the screen deliberately does not race to
/// disappear. An answer that arrives instantly reads as a lookup, and this one
/// is supposed to read as something that was worked out.
@RoutePage()
class CalculatingPage extends StatelessWidget implements AutoRouteWrapper {
  const CalculatingPage({super.key});

  static const _minimumDwell = Duration(milliseconds: 1800);

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (_) => getIt<TestCubit>()..unawaitedSubmit(),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TestCubit, TestState>(
      listenWhen: (previous, current) =>
          previous.result != current.result ||
          previous.errorCode != current.errorCode,
      listener: (context, state) async {
        if (state.result != null) {
          await Future<void>.delayed(_minimumDwell);
          if (context.mounted) {
            // The shell first, then the result on top of it: closing the card
            // should land on today, not on a screen with nowhere to go back
            // to. "Zincirini başlat" then becomes a pop rather than a push.
            await context.router.replaceAll([
              const ShellRoute(),
              ResultRoute(result: state.result!),
            ]);
          }
        }
      },
      builder: (context, state) => Scaffold(
        body: Center(
          child: state.status == TestStatus.failed
              ? _Failed(code: state.errorCode)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Cevapların okunuyor',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({this.code});

  final String? code;

  /// The API answers with a code; the sentence belongs to the app, in the
  /// app's language. A message from a server is a message in whatever language
  /// the server was written in.
  String get _message => switch (code) {
    'cooldown_open' => 'Yeni bir motto için biraz beklemen gerekiyor.',
    'no_uses_left' => 'Ücretsiz hakların doldu.',
    'no_skips_left' => 'Atlama hakkın kalmadı.',
    _ => 'Sonucun alınamadı.',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.router.maybePop(),
            child: const Text('Geri dön'),
          ),
        ],
      ),
    );
  }
}
