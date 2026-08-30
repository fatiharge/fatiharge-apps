import 'package:motto/infrastructure/effects/effect.dart';

/// Everything the app has to be able to do so a definition can ask for it.
///
/// The engine holds no widgets and no router. It decides *what* happens and in
/// what order; the app decides what a sheet looks like and where a route
/// leads. That split is what makes the engine the same in every app.
abstract class EffectHost {
  Future<void> snack(String message);

  /// Which choice was pressed, or null when it was dismissed. Null stops the
  /// run: somebody who closed a sheet did not choose anything, and carrying on
  /// down the list would be answering for them.
  Future<int?> sheet(ShowSheet asked);

  Future<void> goTo(String route);

  /// A request named in the definition. The name, not a URL.
  Future<void> call(String name);

  /// One of the few things the app does to itself.
  Future<void> run(String name);
}

/// What this app is willing to be asked for.
///
/// A definition names a behaviour; it never introduces one. A route this app
/// does not have, a call it cannot make or a method it does not know makes the
/// whole definition unusable — which is the same as having none, and that case
/// already has an answer.
class EffectPermits {
  const EffectPermits({
    required this.routes,
    required this.calls,
    required this.methods,
  });

  const EffectPermits.none()
    : routes = const {},
      calls = const {},
      methods = const {};

  final Set<String> routes;
  final Set<String> calls;
  final Set<String> methods;

  bool allows(Effect effect) => switch (effect) {
    GoTo(:final route) => routes.contains(route),
    CallNamed(:final name) => calls.contains(name),
    RunNamed(:final name) => methods.contains(name),
    ShowSheet(:final choices) => choices.every(
      (choice) => choice.then.every(allows),
    ),
    ShowSnack() => true,
  };
}
