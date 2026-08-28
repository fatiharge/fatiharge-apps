import 'package:meta/meta.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

enum DailyStatus { loading, ready, noResultYet, noContent, failed }

@immutable
class DailyState {
  const DailyState({
    this.status = DailyStatus.loading,
    this.content,
    this.keptYesterday,
    this.tomorrow,
    this.pool = const [],
    this.archetypes = const [],
    this.mine,
    this.resultId,
  });

  final DailyStatus status;

  final DailyContent? content;

  /// Null before the chain has started — there is no yesterday to have kept.
  final bool? keptYesterday;

  /// What tomorrow asks for, by name. A day that ends without saying what the
  /// next one is is a day with no reason to come back to.
  final String? tomorrow;

  /// The archetype's four mottos. Written from the start and unreachable until
  /// a period could end — three of every four were never seen by anybody.
  final List<PackMotto> pool;

  /// Every archetype the package knows, for the gallery.
  final List<PackArchetype> archetypes;

  /// This device's archetype, read from the package rather than the server, so
  /// the way into the result survives a dead network.
  final PackArchetype? mine;

  /// Which result that archetype came from.
  final int? resultId;
}
