import 'package:meta/meta.dart';

/// The content package, as the app actually uses it.
///
/// Parsed once from whatever the content repository handed over — downloaded,
/// shipped or fresh — so that everything above this line works on typed values
/// rather than on a map full of dynamic.
@immutable
class ContentPack {
  const ContentPack({
    required this.version,
    required this.skeletons,
    required this.fragments,
    required this.connectors,
    required this.mottos,
  });

  factory ContentPack.fromJson(Map<String, dynamic> json) => ContentPack(
    version: json['version'] as String,
    skeletons: [
      for (final item in json['skeletons'] as List<dynamic>)
        DaySkeleton.fromJson(item as Map<String, dynamic>),
    ],
    fragments: [
      for (final item in json['fragments'] as List<dynamic>)
        DayFragment.fromJson(item as Map<String, dynamic>),
    ],
    connectors: [
      for (final item in json['connectors'] as List<dynamic>)
        (item as Map<String, dynamic>)['text'] as String,
    ],
    mottos: [
      for (final item in json['mottos'] as List<dynamic>)
        PackMotto.fromJson(item as Map<String, dynamic>),
    ],
  );

  final String version;
  final List<DaySkeleton> skeletons;
  final List<DayFragment> fragments;
  final List<String> connectors;
  final List<PackMotto> mottos;

  List<DayFragment> fragmentsFor(String archetypeId) => [
    for (final fragment in fragments)
      if (fragment.archetypeId == archetypeId) fragment,
  ]..sort((a, b) => a.index.compareTo(b.index));
}

@immutable
class DaySkeleton {
  const DaySkeleton({
    required this.day,
    required this.title,
    required this.body,
    required this.action,
  });

  factory DaySkeleton.fromJson(Map<String, dynamic> json) => DaySkeleton(
    day: json['day'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    action: json['action'] as String,
  );

  final int day;
  final String title;
  final String body;

  /// The minute. Doable while standing in a queue, or the chain breaks on the
  /// first bad day.
  final String action;
}

@immutable
class DayFragment {
  const DayFragment({
    required this.archetypeId,
    required this.index,
    required this.text,
  });

  factory DayFragment.fromJson(Map<String, dynamic> json) => DayFragment(
    archetypeId: json['archetypeId'] as String,
    index: json['index'] as int,
    text: json['text'] as String,
  );

  final String archetypeId;
  final int index;
  final String text;
}

@immutable
class PackMotto {
  const PackMotto({
    required this.id,
    required this.archetypeId,
    required this.motto,
    required this.detail,
    required this.reminder,
  });

  factory PackMotto.fromJson(Map<String, dynamic> json) => PackMotto(
    id: json['id'] as String,
    archetypeId: json['archetypeId'] as String,
    motto: json['motto'] as String,
    detail: json['detail'] as String,
    reminder: json['reminder'] as String,
  );

  final String id;
  final String archetypeId;
  final String motto;
  final String detail;
  final String reminder;
}
