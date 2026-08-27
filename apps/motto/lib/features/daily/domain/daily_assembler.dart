import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

/// Builds a day out of the pieces.
///
/// Fourteen bodies, four fragments per archetype and ten connectors make a
/// hundred and twelve readable days from forty-six pieces. The risk is that it
/// reads generic; the defences are that the connectors are written by hand and
/// that the number of slots stays this low.
abstract final class DailyAssembler {
  static const cycleDays = 14;

  /// Which of the fourteen days a chain of [daysMarked] length is on.
  ///
  /// One-based, and it wraps: day 15 is day 1 again. A chain that outlives the
  /// content is a good problem, and repeating beats stopping.
  static int dayIndex(int daysMarked) {
    final position = daysMarked < 1 ? 0 : daysMarked - 1;
    return (position % cycleDays) + 1;
  }

  /// Null when there is no result yet — there is nothing personal to say to
  /// someone who has not taken the inventory, and saying something general
  /// would be exactly the horoscope this is trying not to be.
  static DailyContent? assemble({
    required ContentPack pack,
    required String? archetypeId,
    required int daysMarked,
  }) {
    if (archetypeId == null) return null;

    final fragments = pack.fragmentsFor(archetypeId);
    if (fragments.isEmpty || pack.connectors.isEmpty) return null;

    final day = dayIndex(daysMarked);
    final skeleton = pack.skeletons.firstWhere(
      (candidate) => candidate.day == day,
      orElse: () => pack.skeletons.first,
    );

    // Both cycle on the day, and their lengths are coprime with each other
    // over fourteen days — so no body ever meets the same connector and
    // fragment twice inside one run.
    final fragment = fragments[(day - 1) % fragments.length];
    final connector = pack.connectors[(day - 1) % pack.connectors.length];

    return DailyContent(
      day: day,
      title: skeleton.title,
      body: skeleton.body,
      connector: connector,
      fragment: fragment.text,
      action: skeleton.action,
      motto: _mottoFor(pack, archetypeId),
    );
  }

  /// Their own line, the one on the card they shared — not a rotating one. The
  /// day changes; the motto is the thing that does not.
  static String _mottoFor(ContentPack pack, String archetypeId) {
    for (final motto in pack.mottos) {
      if (motto.archetypeId == archetypeId) return motto.motto;
    }
    return '';
  }
}
