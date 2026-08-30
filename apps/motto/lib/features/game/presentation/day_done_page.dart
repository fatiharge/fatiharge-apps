import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/game/presentation/open_game.dart';

/// The day's three things are done.
///
/// A screen rather than a line on the list: this is the only moment the app
/// has to say the work was worth something, and a sentence that appears where
/// a checkbox just was gets read as part of the checkbox.
@RoutePage()
class DayDonePage extends StatefulWidget {
  const DayDonePage({super.key});

  @override
  State<DayDonePage> createState() => _DayDonePageState();
}

class _DayDonePageState extends State<DayDonePage> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2))
      ..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text('Tebrikler', style: text.displaySmall),
                  const SizedBox(height: 12),
                  Text(
                    'Bugünün üç şeyi de bitti. Zincir bir gün daha uzadı.',
                    style: text.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+3 OYUN HAKKI',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.7,
                            ),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Günün üçünü de bitirmek üç hak kazandırıyor.',
                          style: text.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const FilledButton(
                    onPressed: openGame,
                    child: Text('Oyna'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.router.maybePop(),
                    child: const Text('Sonra'),
                  ),
                ],
              ),
            ),
          ),
          // Above the text rather than behind it: the burst is the whole point
          // of the screen and a burst behind a card is a card that flickered.
          IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              emissionFrequency: 0.06,
              numberOfParticles: 14,
              gravity: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
