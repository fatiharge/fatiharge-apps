package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.content.write.ArchetypeWrite;
import com.dafalabs.api.motto.content.write.ContentWriter;
import com.dafalabs.api.motto.content.write.FragmentWrite;
import com.dafalabs.api.motto.content.write.MottoWrite;
import com.dafalabs.api.motto.scoring.ArchetypeRules;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The reason the words are rows.
 *
 * <p>Eighteen archetypes today and thirty-two the week after should be the
 * same amount of Java: none. Everything here goes in through the write side,
 * and then the reading side — matching, the content package, the day the app
 * assembles — has to already know about it.
 */
@QuarkusTest
class NineteenthArchetypeTest {

  private static final String id = "night_shift";

  @Inject ContentWriter writer;
  @Inject ContentCatalog catalog;
  @Inject ArchetypeRules rules;

  private static Map<String, Double> target() {
    // A corner nothing else occupies: the pool's extremes are all mid-range on
    // at least one axis, so this point is free.
    return Map.of(
        "openness", 0.92,
        "conscientiousness", 0.08,
        "extraversion", 0.08,
        "agreeableness", 0.92,
        "neuroticism", 0.92);
  }

  private static ArchetypeWrite archetype() {
    return new ArchetypeWrite(
        id,
        "Gece Vardiyası",
        "Gündüz kimsenin göremediği şeyleri gece görüyorsun. Bedeli, herkes uyanıkken senin yorgun olman.",
        "Kendi saatimde çalışırım.",
        99,
        List.of("openness", "neuroticism"),
        target());
  }

  /// Written by whichever test runs first; the write is addressed by id, so
  /// the second one is a no-op rather than a conflict.
  @BeforeEach
  void given() {
    writer.archetypes(List.of(archetype()));
  }

  @Test
  @DisplayName("an archetype nobody wrote code for is reachable the moment it is written")
  void oneRequestIsTheWholeChange() {
    int before = rules.size();

    List<FragmentWrite> fragments = new ArrayList<>();
    for (int day = 1; day <= 14; day++) {
      fragments.add(new FragmentWrite(id, day, "Gün %d: kendi saatinde.".formatted(day)));
    }
    writer.fragments(fragments);
    writer.mottos(
        List.of(
            new MottoWrite(
                id + "_1",
                id,
                "Kendi saatimde çalışırım.",
                "Herkesin uyandığı saatte değil, işin çıktığı saatte.",
                "Bugünün bir saati senin.",
                1)));

    assertEquals(before, rules.size());

    // Matching: somebody landing on that point is told this, and nothing in
    // the matcher was touched to make it so.
    Map<Dimension, Double> profile = new EnumMap<>(Dimension.class);
    target().forEach((name, value) -> profile.put(Dimension.of(name), value));
    assertEquals(id, rules.match(new ProfileVector(profile)));

    // Reading: the package a phone downloads carries it, with its days.
    var bundle = catalog.bundle();
    assertTrue(bundle.archetypes().stream().anyMatch(a -> a.id().equals(id)));
    assertEquals(14, bundle.fragments().stream().filter(f -> f.archetypeId().equals(id)).count());
    assertTrue(bundle.mottos().stream().anyMatch(m -> m.archetypeId().equals(id)));

    // And the version moved, so phones holding the old package are told.
    assertTrue(bundle.version().length() == 12);
  }

  @Test
  @DisplayName("an archetype too close to another to be told apart is refused")
  void unreachableIsRefused() {
    Map<String, Double> shadowed = new java.util.HashMap<>(target());
    shadowed.put("openness", 0.93);

    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                writer.archetypes(
                    List.of(
                        new ArchetypeWrite(
                            "night_shift_twin",
                            "İkiz",
                            "Aynı yerde duruyor.",
                            "Aynı saat.",
                            100,
                            List.of("openness", "neuroticism"),
                            shadowed))));

    assertEquals("archetype_unreachable", refused.code());
  }

  @Test
  @DisplayName("words guideline 1.4.1 reads as a health claim never reach a table")
  void forbiddenWordsAreRefused() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                writer.archetypes(
                    List.of(
                        new ArchetypeWrite(
                            "clinician",
                            "Teşhis Koyan",
                            "Kişilik testi sonucun bu.",
                            "Ölç ve söyle.",
                            101,
                            List.of("openness"),
                            target()))));

    assertEquals("forbidden_words", refused.code());
  }
}
