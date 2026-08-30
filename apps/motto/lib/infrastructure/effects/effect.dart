import 'package:meta/meta.dart';

/// What the app does about a named refusal.
///
/// Written as data rather than code so the answer to "the server said
/// `birth_date_required`, now what" is something somebody edits, not something
/// somebody ships. Nothing here knows what app it is running in.
///
/// The kinds are a closed set on purpose: a string from a server names a
/// behaviour, it never chooses one. Anything unrecognised makes the whole
/// definition unusable, and an unusable definition is the same as no
/// definition — which is already handled.
@immutable
sealed class Effect {
  const Effect();

  /// Null when anything in the definition is not understood. The caller reads
  /// that as "we do not know what to do about this code".
  static Effect? fromJson(Map<String, dynamic> json) {
    switch (json['kind']) {
      case 'snack':
        final message = _string(json, 'message');
        return message == null ? null : ShowSnack(message);
      case 'sheet':
      case 'bottom_sheet':
        return _sheet(json);
      case 'navigate':
        final route = _string(json, 'to');
        return route == null ? null : GoTo(route);
      case 'call':
        final name = _string(json, 'name');
        return name == null ? null : CallNamed(name);
      case 'method':
        final name = _string(json, 'name');
        return name == null ? null : RunNamed(name);
      default:
        return null;
    }
  }

  static Effect? _sheet(Map<String, dynamic> json) {
    final title = _string(json, 'title');
    final body = _string(json, 'body');
    if (title == null || body == null) return null;

    final choices = <EffectChoice>[];
    for (final raw in (json['choices'] as List<dynamic>? ?? const [])) {
      if (raw is! Map<String, dynamic>) return null;
      final choice = EffectChoice.fromJson(raw);
      if (choice == null) return null;
      choices.add(choice);
    }

    return ShowSheet(
      title: title,
      body: body,
      choices: choices,
      bottom: json['kind'] == 'bottom_sheet',
    );
  }

  static String? _string(Map<String, dynamic> json, String key) =>
      json[key] is String && (json[key] as String).isNotEmpty
      ? json[key] as String
      : null;
}

/// A line that appears and goes away. For things somebody does not have to act
/// on.
final class ShowSnack extends Effect {
  const ShowSnack(this.message);

  final String message;
}

/// Says what happened and offers what to do about it. The choices carry their
/// own effects, which is how "tell them, then take them there" is one
/// definition rather than two.
final class ShowSheet extends Effect {
  const ShowSheet({
    required this.title,
    required this.body,
    required this.choices,
    required this.bottom,
  });

  final String title;
  final String body;
  final List<EffectChoice> choices;

  /// Bottom sheet rather than a dialog. The same words either way; only how
  /// much of the screen it takes.
  final bool bottom;
}

/// Somewhere else in the app. The name is checked against what this app
/// actually has before anything moves.
final class GoTo extends Effect {
  const GoTo(this.route);

  final String route;
}

/// A request the app knows how to make, by name. Never a URL: a definition
/// that can name an endpoint is a definition that can point one somewhere
/// else.
final class CallNamed extends Effect {
  const CallNamed(this.name);

  final String name;
}

/// One of the few things an app can be asked to do to itself — signing out is
/// the only one anybody has needed so far.
final class RunNamed extends Effect {
  const RunNamed(this.name);

  final String name;
}

/// A button on a sheet, and what pressing it does.
@immutable
class EffectChoice {
  const EffectChoice({required this.label, required this.then});

  final String label;
  final List<Effect> then;

  static EffectChoice? fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    if (label is! String || label.isEmpty) return null;

    final then = <Effect>[];
    for (final raw in (json['then'] as List<dynamic>? ?? const [])) {
      if (raw is! Map<String, dynamic>) return null;
      final effect = Effect.fromJson(raw);
      if (effect == null) return null;
      then.add(effect);
    }
    return EffectChoice(label: label, then: then);
  }
}
