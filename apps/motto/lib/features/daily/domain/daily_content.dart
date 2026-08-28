import 'package:meta/meta.dart';
import 'package:motto/features/daily/domain/content_pack.dart';

@immutable
class DailyContent {
  const DailyContent({
    required this.day,
    required this.title,
    required this.body,
    required this.connector,
    required this.fragment,
    required this.action,
    required this.motto,
  });

  final int day;

  final String title;

  final String body;

  /// The hand-written join. Without it every day reads like one template with
  /// a different ending.
  final String connector;

  final String fragment;

  final String action;

  /// The whole motto, not only the line. What it means and what it costs are
  /// written next to it and were reaching the app without ever being drawn.
  final PackMotto motto;

  String get text => '$body $connector $fragment';

  String get mottoLine => motto.motto;
}
