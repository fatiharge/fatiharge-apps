package com.dafalabs.api.motto.scoring;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Which archetype a profile lands on.
 *
 * <p>A table rather than a chain of conditions, so that adding four more is
 * adding four rows. And nearest-point rather than thresholds, because every
 * profile has to land somewhere — a threshold chain leaves gaps, and a gap is a
 * user with no result.
 */
@ApplicationScoped
public class ArchetypeRules {

  private static final String RESOURCE = "scoring/archetype-rules.yaml";

  private record Rule(String id, Set<Dimension> defining, Map<Dimension, Double> target) {}

  private final List<Rule> rules = new ArrayList<>();
  private double backgroundWeight;

  @PostConstruct
  void load() {
    try (InputStream stream = Thread.currentThread().getContextClassLoader()
        .getResourceAsStream(RESOURCE)) {
      if (stream == null) {
        throw new IllegalStateException(RESOURCE + " is not on the classpath");
      }
      JsonNode root = new YAMLMapper().readTree(stream);
      backgroundWeight = root.path("background_weight").asDouble(0.25);

      for (JsonNode node : root.withArray("archetypes")) {
        Set<Dimension> defining = EnumSet.noneOf(Dimension.class);
        node.withArray("defining").forEach(d -> defining.add(Dimension.of(d.asText())));

        Map<Dimension, Double> target = new EnumMap<>(Dimension.class);
        node.get("target")
            .properties()
            .forEach(entry -> target.put(Dimension.of(entry.getKey()), entry.getValue().asDouble()));

        rules.add(new Rule(node.get("id").asText(), defining, target));
      }
    } catch (IOException unreadable) {
      throw new IllegalStateException("could not read " + RESOURCE, unreadable);
    }
  }

  /** The nearest archetype. Ties go to the earlier row, so the answer is stable. */
  public String match(ProfileVector profile) {
    Rule best = null;
    double bestDistance = Double.MAX_VALUE;

    for (Rule rule : rules) {
      double distance = distance(profile, rule);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = rule;
      }
    }
    return best.id();
  }

  private double distance(ProfileVector profile, Rule rule) {
    double sum = 0;
    for (Dimension dimension : Dimension.values()) {
      double gap = profile.at(dimension) - rule.target().getOrDefault(dimension, 0.5);
      double weight = rule.defining().contains(dimension) ? 1.0 : backgroundWeight;
      sum += weight * gap * gap;
    }
    return sum;
  }

  public int size() {
    return rules.size();
  }
}
