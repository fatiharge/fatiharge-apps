import 'package:api_client_motto/api.dart' as api;

/// The things the test flow does once.
sealed class TestEffect {
  const TestEffect();
}

/// Partway through: what they would be if they stopped here.
class GlimpseOffered extends TestEffect {
  const GlimpseOffered(this.archetype);

  final api.ArchetypeResponse archetype;
}

/// The twentieth answer is in.
class AnsweringFinished extends TestEffect {
  const AnsweringFinished();
}

/// A use was spent and the result is theirs.
class ResultClaimed extends TestEffect {
  const ResultClaimed(this.result);

  final api.ResultResponse result;
}
