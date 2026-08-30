import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

/// Builds a day out of the pieces: fourteen bodies, ten hand-written
/// connectors, and one fragment per archetype per day — two hundred and fifty
/// two days of text, none of which repeats inside a period.
abstract final class DailyAssembler {
  static const cycleDays = 14;

  static int dayIndex(int daysMarked) {
    final position = daysMarked < 1 ? 0 : daysMarked - 1;
    return (position % cycleDays) + 1;
  }

  /// The count that stands for tomorrow.
  ///
  /// Nothing marked and one day marked are both day one — the first day is
  /// day one whether or not it has been ticked. Adding one to a count of zero
  /// therefore gave day one again, and tomorrow showed today's text until the
  /// chain had started.
  static int tomorrowFrom(int daysMarked) =>
      (daysMarked < 1 ? 1 : daysMarked) + 1;

  /// Null without a result: saying something general would be the horoscope
  /// this is trying not to be.
  static DailyContent? assemble({
    required ContentPack pack,
    required String? archetypeId,
    required int daysMarked,
    String? mottoId,
  }) {
    if (archetypeId == null) return null;

    final fragments = pack.fragmentsFor(archetypeId);
    if (fragments.isEmpty || pack.connectors.isEmpty) return null;

    final motto = _mottoFor(pack, archetypeId, mottoId);
    if (motto == null) return null;

    final day = dayIndex(daysMarked);
    final skeleton = pack.skeletons.firstWhere(
      (candidate) => candidate.day == day,
      orElse: () => pack.skeletons.first,
    );

    // Four and ten do not repeat a pair inside fourteen days.
    final fragment = fragments[(day - 1) % fragments.length];
    final connector = pack.connectors[(day - 1) % pack.connectors.length];

    return DailyContent(
      day: day,
      title: skeleton.title,
      body: skeleton.body,
      connector: connector,
      fragment: fragment.text,
      action: skeleton.action,
      motto: motto,
    );
  }

  /// The one this run is under, and the archetype's first when it is the
  /// first run.
  ///
  /// The screen at the end of a period has offered the other three for a while
  /// and the server has been recording the answer. This did not read it, so
  /// the app let somebody choose a motto, kept the choice, and then went on
  /// showing them a different one — and three of every four written mottos
  /// stayed unreachable.
  static PackMotto? _mottoFor(
    ContentPack pack,
    String archetypeId,
    String? chosen,
  ) {
    PackMotto? first;
    for (final motto in pack.mottos) {
      if (motto.archetypeId != archetypeId) continue;
      if (motto.id == chosen) return motto;
      first ??= motto;
    }
    // A choice the package no longer has falls back rather than emptying the
    // screen: a motto that was retired is not a reason to have no day.
    return first;
  }
}
