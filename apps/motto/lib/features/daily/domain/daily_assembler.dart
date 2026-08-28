import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

/// Builds a day out of the pieces: fourteen bodies, four fragments per
/// archetype, ten hand-written connectors — a hundred and twelve days from
/// forty-six pieces.
abstract final class DailyAssembler {
  static const cycleDays = 14;

  static int dayIndex(int daysMarked) {
    final position = daysMarked < 1 ? 0 : daysMarked - 1;
    return (position % cycleDays) + 1;
  }

  /// Null without a result: saying something general would be the horoscope
  /// this is trying not to be.
  static DailyContent? assemble({
    required ContentPack pack,
    required String? archetypeId,
    required int daysMarked,
  }) {
    if (archetypeId == null) return null;

    final fragments = pack.fragmentsFor(archetypeId);
    if (fragments.isEmpty || pack.connectors.isEmpty) return null;

    final motto = _mottoFor(pack, archetypeId);
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

  /// The archetype's first motto.
  ///
  /// First, not chosen: the pool of four exists so that a second period can
  /// start on a different one, and nothing chooses yet. Until it does, three
  /// of every four written mottos are unreachable.
  static PackMotto? _mottoFor(ContentPack pack, String archetypeId) {
    for (final motto in pack.mottos) {
      if (motto.archetypeId == archetypeId) return motto;
    }
    return null;
  }
}
