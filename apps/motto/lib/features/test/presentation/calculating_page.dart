import 'dart:async';
import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/effects.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/test/application/test_cubit.dart';
import 'package:motto/features/test/application/test_effect.dart';
import 'package:motto/features/test/application/test_state.dart';
import 'package:motto/route/app_router.gr.dart';
import 'package:motto/theme/motto_loading.dart';

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
    // An effect rather than a state difference: a result is claimed once, and
    // `result != null` goes on being true after it has been opened.
    return EffectListener<TestCubit, TestEffect>(
      bloc: context.read<TestCubit>(),
      onEffect: (context, effect) async {
        if (effect is! ResultClaimed) return;
        await Future<void>.delayed(_minimumDwell);
        if (!context.mounted) return;
        // The shell first, then the result on top of it: closing the card
        // should land on today, not on a screen with nowhere to go back to.
        // "Zincirini başlat" then becomes a pop rather than a push.
        await context.router.replaceAll([
          const ShellRoute(),
          ResultRoute(
            archetype: effect.result.archetype,
            resultId: effect.result.id,
            justClaimed: true,
          ),
        ]);
      },
      child: BlocBuilder<TestCubit, TestState>(
        builder: (context, state) => Scaffold(
          body: Center(
            child: state.status == TestStatus.failed
                ? _Failed(code: state.errorCode)
                : const MottoLoading(label: 'Cevapların okunuyor'),
          ),
        ),
      ),
    );
  }
}

class _Failed extends StatefulWidget {
  const _Failed({this.code});

  final String? code;

  @override
  State<_Failed> createState() => _FailedState();
}

class _FailedState extends State<_Failed> {
  int _skipsLeft = 0;
  bool _spending = false;

  String? get code => widget.code;

  @override
  void initState() {
    super.initState();
    if (code == 'cooldown_open') unawaited(_loadSkips());
  }

  /// The claim's refusal does not say how many skips are left, and the whole
  /// point of a skip is that it opens a closed cooldown — so the screen that
  /// reports the cooldown is the one screen that has to know.
  Future<void> _loadSkips() async {
    try {
      final state = await getIt<api.EntitlementResourceApi>()
          .currentEntitlement();
      if (mounted) setState(() => _skipsLeft = state?.skipsLeft ?? 0);
    } on Object {
      // Then it simply is not offered.
    }
  }

  Future<void> _spendSkip() async {
    setState(() => _spending = true);
    await context.read<TestCubit>().submitSaved(spendSkip: true);
    if (mounted) setState(() => _spending = false);
  }

  /// The API answers with a code; the sentence belongs to the app, in the
  /// app's language.
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
          if (code == 'cooldown_open' && _skipsLeft > 0) ...[
            Text(
              'Bir atlama hakkın var. Kullanırsan beklemeden devam edersin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _spending ? null : _spendSkip,
              child: Text(
                _spending ? 'Bekle…' : 'Atlama hakkımı kullan ($_skipsLeft)',
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.router.maybePop(),
              child: const Text('Beklerim'),
            ),
          ] else
            FilledButton(
              onPressed: () => context.router.maybePop(),
              child: const Text('Geri dön'),
            ),
        ],
      ),
    );
  }
}
