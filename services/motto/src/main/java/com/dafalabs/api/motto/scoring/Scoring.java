package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/** Answers in, a profile vector out. */
@ApplicationScoped
public class Scoring {

  private final ItemPool items;

  Scoring(ItemPool items) {
    this.items = items;
  }

  /**
   * Averages each dimension over the items answered for it, so a partial set
   * scores on what it has rather than on a set of zeroes it never saw.
   */
  public ProfileVector score(Map<String, Integer> answers) {
    validate(answers);

    Map<Dimension, Double> totals = new EnumMap<>(Dimension.class);
    Map<Dimension, Integer> counts = new EnumMap<>(Dimension.class);

    for (Map.Entry<String, Integer> answer : answers.entrySet()) {
      Item item = items.byId(answer.getKey());
      double normalised = normalise(answer.getValue());
      if (item.reverse()) {
        normalised = 1.0 - normalised;
      }
      totals.merge(item.dimension(), normalised, Double::sum);
      counts.merge(item.dimension(), 1, Integer::sum);
    }

    Map<Dimension, Double> vector = new EnumMap<>(Dimension.class);
    for (Dimension dimension : Dimension.values()) {
      // A dimension nobody answered for sits in the middle rather than at zero:
      // unknown is not the same as low.
      vector.put(
          dimension,
          counts.containsKey(dimension)
              ? totals.get(dimension) / counts.get(dimension)
              : 0.5);
    }
    return new ProfileVector(vector);
  }

  private double normalise(int answer) {
    return (answer - 1.0) / (items.likertPoints() - 1.0);
  }

  private void validate(Map<String, Integer> answers) {
    if (answers == null || answers.isEmpty()) {
      throw new CustomRuntimeException(400, "no_answers", "No answers were submitted.");
    }

    Set<String> unknown = new HashSet<>();
    for (Map.Entry<String, Integer> answer : answers.entrySet()) {
      if (items.byId(answer.getKey()) == null) {
        unknown.add(answer.getKey());
      }
      int value = answer.getValue() == null ? 0 : answer.getValue();
      if (value < 1 || value > items.likertPoints()) {
        throw new CustomRuntimeException(
            400,
            "answer_out_of_range",
            "Answer for %s must be between 1 and %d."
                .formatted(answer.getKey(), items.likertPoints()));
      }
    }
    if (!unknown.isEmpty()) {
      throw new CustomRuntimeException(
          400, "unknown_item", "No such items: " + String.join(", ", unknown));
    }
  }
}
