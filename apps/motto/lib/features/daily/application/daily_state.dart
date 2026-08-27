import 'package:meta/meta.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

enum DailyStatus { loading, ready, noResultYet }

@immutable
class DailyState {
  const DailyState({this.status = DailyStatus.loading, this.content});

  final DailyStatus status;

  /// Null until there is a result to build a day out of.
  final DailyContent? content;
}
