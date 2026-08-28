import 'package:meta/meta.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

enum DailyStatus { loading, ready, noResultYet, noContent, failed }

@immutable
class DailyState {
  const DailyState({
    this.status = DailyStatus.loading,
    this.content,
    this.keptYesterday,
    this.tomorrow,
  });

  final DailyStatus status;

  final DailyContent? content;

  /// Null before the chain has started — there is no yesterday to have kept.
  final bool? keptYesterday;

  /// What tomorrow asks for, by name. A day that ends without saying what the
  /// next one is is a day with no reason to come back to.
  final String? tomorrow;
}
