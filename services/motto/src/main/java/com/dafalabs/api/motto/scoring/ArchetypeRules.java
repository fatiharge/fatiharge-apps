package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.RuleRow;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Which archetype a profile lands on.
 *
 * <p>A table rather than a chain of conditions, so that adding fourteen more
 * is adding fourteen rows. Nearest-point rather than thresholds, because every
 * profile has to land somewhere — a threshold chain leaves gaps, and a gap is
 * a user with no result.
 */
@ApplicationScoped
public class ArchetypeRules {

  /// How much a dimension the archetype does not name still counts. The one
  /// number here that is not a row: it is the shape of the metric itself, and
  /// changing it moves everybody at once.
  public static final double backgroundWeight = 0.25;

  public record Rule(String id, Set<Dimension> defining, Map<Dimension, Double> target) {}

  private final ContentStore content;

  ArchetypeRules(ContentStore content) {
    this.content = content;
  }

  /** The nearest archetype. Ties go to the earlier row, so the answer is stable. */
  public String match(ProfileVector profile) {
    return nearest(profile, all());
  }

  /** The same question asked of a set of rules that is not live yet. */
  public static String nearest(ProfileVector profile, List<Rule> rules) {
    Rule best = null;
    double bestDistance = Double.MAX_VALUE;

    for (Rule rule : rules) {
      double distance = distance(profile, rule);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = rule;
      }
    }
    return best == null ? null : best.id();
  }

  public List<Rule> all() {
    List<Rule> rules = new ArrayList<>();
    for (RuleRow row : content.rules()) {
      rules.add(ruleOf(row.archetypeId(), row.defining(), row.target()));
    }
    return rules;
  }

  public static Rule ruleOf(String id, List<String> defining, Map<String, Double> target) {
    Set<Dimension> named = EnumSet.noneOf(Dimension.class);
    defining.forEach(d -> named.add(Dimension.of(d)));

    Map<Dimension, Double> point = new EnumMap<>(Dimension.class);
    target.forEach((name, value) -> point.put(Dimension.of(name), value));

    return new Rule(id, named, point);
  }

  private static double distance(ProfileVector profile, Rule rule) {
    double sum = 0;
    for (Dimension dimension : Dimension.values()) {
      double gap = profile.at(dimension) - rule.target().getOrDefault(dimension, 0.5);
      double weight = rule.defining().contains(dimension) ? 1.0 : backgroundWeight;
      sum += weight * gap * gap;
    }
    return sum;
  }

  public int size() {
    return content.rules().size();
  }
}
