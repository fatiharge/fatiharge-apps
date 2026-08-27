import 'package:meta/meta.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

enum DailyStatus { loading, ready, noResultYet, noContent }

@immutable
class DailyState {
  const DailyState({this.status = DailyStatus.loading, this.content});

  final DailyStatus status;

  final DailyContent? content;
}
