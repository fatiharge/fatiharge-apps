import 'package:meta/meta.dart';

/// One day, assembled.
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

  /// 1 to 14, and it repeats. Fourteen days is the measurement; what happens
  /// after it is the same fourteen with a chain that is no longer new.
  final int day;

  final String title;

  /// The part everybody gets.
  final String body;

  /// The hand-written join. Without it the seam between body and fragment
  /// shows, and every day starts to read like the same template with a
  /// different ending — which is what a horoscope is.
  final String connector;

  /// The part only this archetype gets.
  final String fragment;

  /// The minute.
  final String action;

  /// Their line, the same one on the card they shared.
  final String motto;

  /// What the day reads as, in one block.
  String get text => '$body $connector $fragment';
}
