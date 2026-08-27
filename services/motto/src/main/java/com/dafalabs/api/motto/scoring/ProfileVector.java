package com.dafalabs.api.motto.scoring;

import java.util.EnumMap;
import java.util.Map;

/**
 * Where a set of answers lands, each dimension between 0 and 1.
 *
 * <p>Continuous on purpose. Fixing an archetype as a combination of high/low
 * flags looks tidy and then has nowhere to go: eight is 2³, and the next number
 * that shape offers is sixteen, not twelve.
 */
public record ProfileVector(Map<Dimension, Double> scores) {

  public ProfileVector {
    scores = new EnumMap<>(scores);
  }

  public double at(Dimension dimension) {
    return scores.getOrDefault(dimension, 0.5);
  }
}
