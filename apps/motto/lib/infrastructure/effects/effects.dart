import 'package:injectable/injectable.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/infrastructure/effects/effect.dart';
import 'package:motto/infrastructure/effects/effect_catalogue.dart';
import 'package:motto/infrastructure/effects/effect_host.dart';

/// Runs what a refusal is supposed to lead to.
///
/// One place, so a cubit's whole answer to "the server said no" is a single
/// call — and the only refusals a cubit writes code for are the ones that
/// change what its own screen shows.
@lazySingleton
class Effects {
  Effects(this._catalogue, this._host, this._permits);

  final EffectCatalogue _catalogue;
  final EffectHost _host;
  final EffectPermits _permits;

  /// How deep a definition may go: the list itself, and one nesting from a
  /// choice somebody pressed. Deeper than that is a definition arguing with
  /// itself, and it is how a run would never end.
  static const _deepest = 2;

  int _depth = 0;

  /// True when this code had a definition and it ran.
  ///
  /// False means the app does not know what this refusal is — which is the
  /// caller's cue to say so plainly rather than invent an answer.
  Future<bool> forCode(String code) async {
    final defined = _catalogue.forCode(code);
    if (defined == null || defined.isEmpty) return false;

    // A definition that asks for something this app does not have is not
    // half-usable. Running the part we understand would leave somebody
    // stranded between two steps.
    if (!defined.every(_permits.allows)) {
      reported(
        'effects',
        StateError('$code asks for what this app has not'),
        StackTrace.current,
      );
      return false;
    }

    // The call an effect makes can fail, and its failure arrives here again.
    // Without this the app answers a refusal by causing it.
    if (_depth >= _deepest) {
      reported(
        'effects',
        StateError('$code went round again'),
        StackTrace.current,
      );
      return false;
    }

    _depth++;
    try {
      await _run(defined);
      return true;
    } finally {
      _depth--;
    }
  }

  Future<void> _run(List<Effect> effects) async {
    // In order, each waiting for the one before it: a sheet that says what
    // happened has to be answered before the app moves somewhere else.
    for (final effect in effects) {
      switch (effect) {
        case ShowSnack(:final message):
          await _host.snack(message);
        case GoTo(:final route):
          await _host.goTo(route);
        case CallNamed(:final name):
          await _host.call(name);
        case RunNamed(:final name):
          await _host.run(name);
        case ShowSheet(:final choices):
          final chosen = await _host.sheet(effect);
          // Dismissed. Somebody who closed it did not choose, and the rest of
          // the list was the consequence of choosing.
          if (chosen == null) return;
          if (chosen < 0 || chosen >= choices.length) return;
          _depth++;
          try {
            await _run(choices[chosen].then);
          } finally {
            _depth--;
          }
      }
    }
  }
}
