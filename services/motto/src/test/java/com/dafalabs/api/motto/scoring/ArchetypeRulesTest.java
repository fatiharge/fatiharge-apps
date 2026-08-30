package com.dafalabs.api.motto.scoring;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.EnumMap;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ArchetypeRulesTest {

  @Inject ArchetypeRules rules;
  @Inject ArchetypeCatalog catalog;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  /**
   * Every archetype has to win on its own target. It sounds tautological and is
   * not: one archetype's point can sit inside another's weighted pull, and then
   * that archetype is unreachable — a row in the table nobody can ever get.
   *
   * <p>Over the table rather than a list typed here, so the nineteenth is
   * checked the day it is written and nobody has to remember to add it.
   */
  @Test
  @DisplayName("each archetype wins on its own point")
  void everyArchetypeIsReachable() {
    for (ArchetypeRules.Rule rule : rules.all()) {
      assertEquals(rule.id(), rules.match(new ProfileVector(rule.target())));
    }
  }

  @Test
  @DisplayName("the words and the rules cover the same set")
  void tableAndTextAgree() {
    assertEquals(rules.size(), catalog.size("tr"));
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
    assertNotNull(catalog.byId(match, "tr"));
  }
}
