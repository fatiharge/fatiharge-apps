import 'package:meta/meta.dart';

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

  final String motto;

  String get text => '$body $connector $fragment';
}
