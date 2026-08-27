package com.dafalabs.api.motto.scoring;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

@QuarkusTest
class ArchetypeRulesTest {

  @Inject ArchetypeRules rules;
  @Inject ArchetypeCatalog catalog;

  /**
   * Every archetype has to win on its own target. It sounds tautological and is
   * not: one archetype's point can sit inside another's weighted pull, and then
   * that archetype is unreachable — a row in the table nobody can ever get.
   */
  @ParameterizedTest(name = "{0} is reachable")
  @MethodSource("targets")
  @DisplayName("each archetype wins on its own point")
  void everyArchetypeIsReachable(String id, Map<Dimension, Double> target) {
    assertEquals(id, rules.match(new ProfileVector(target)));
  }

  @Test
  @DisplayName("the words and the rules cover the same eight")
  void tableAndTextAgree() {
    assertEquals(rules.size(), catalog.size());
  }

  @Test
  @DisplayName("a profile in the middle of everything still gets an answer")
  void neutralProfileLandsSomewhere() {
    Map<Dimension, Double> middle = new EnumMap<>(Dimension.class);
    for (Dimension dimension : Dimension.values()) {
      middle.put(dimension, 0.5);
    }

    String match = rules.match(new ProfileVector(middle));

    assertNotNull(match);
    assertNotNull(catalog.byId(match));
  }

  static List<org.junit.jupiter.params.provider.Arguments> targets() throws Exception {
    var arguments = new ArrayList<org.junit.jupiter.params.provider.Arguments>();
    try (InputStream stream = Thread.currentThread().getContextClassLoader()
        .getResourceAsStream("scoring/archetype-rules.yaml")) {
      for (JsonNode node : new YAMLMapper().readTree(stream).withArray("archetypes")) {
        Map<Dimension, Double> target = new EnumMap<>(Dimension.class);
        node.get("target")
            .properties()
            .forEach(e -> target.put(Dimension.of(e.getKey()), e.getValue().asDouble()));
        arguments.add(
            org.junit.jupiter.params.provider.Arguments.of(node.get("id").asText(), target));
      }
    }
    return arguments;
  }
}
