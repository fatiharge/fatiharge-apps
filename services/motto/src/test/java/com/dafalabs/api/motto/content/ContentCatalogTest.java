package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.dto.Fragment;
import com.dafalabs.api.motto.scoring.ArchetypeCatalog;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ContentCatalogTest {

  @Inject ContentCatalog catalog;
  @Inject ArchetypeCatalog archetypes;

  @Test
  @DisplayName("the package carries every piece a day is made of")
  void carriesEveryPiece() {
    ContentBundle bundle = catalog.bundle();

    // Counted against the archetype table rather than against a number typed
    // here: adding an archetype should fail this test by leaving one of these
    // short, not by disagreeing with a constant somebody forgot to bump.
    int expected = archetypes.size();
    assertEquals(expected, bundle.archetypes().size());
    assertEquals(14, bundle.skeletons().size());
    assertEquals(expected * 4, bundle.fragments().size());
    assertEquals(expected * 4, bundle.mottos().size());
    assertFalse(bundle.connectors().isEmpty());
  }

  @Test
  @DisplayName("every archetype has four fragments, or some days have no ending")
  void everyArchetypeHasFourFragments() {
    Map<String, Long> perArchetype =
        catalog.bundle().fragments().stream()
            .collect(Collectors.groupingBy(Fragment::archetypeId, Collectors.counting()));

    assertEquals(archetypes.size(), perArchetype.size());
    assertTrue(perArchetype.values().stream().allMatch(count -> count == 4L), "" + perArchetype);
  }

  @Test
  @DisplayName("the days are 1 to 14 with none missing")
  void theDaysAreComplete() {
    Set<Integer> days =
        catalog.bundle().skeletons().stream()
            .map(skeleton -> skeleton.day())
            .collect(Collectors.toSet());

    for (int day = 1; day <= 14; day++) {
      assertTrue(days.contains(day), "day " + day + " is missing");
    }
  }

  @Test
  @DisplayName("the words and the scoring rules name the same archetypes")
  void wordsAndRulesAgree() {
    // Two files, two readers, one truth. This is what it looks like when they
    // stop agreeing — and it looks like a crash at claim time otherwise.
    for (var archetype : catalog.bundle().archetypes()) {
      assertEquals(archetype.id(), archetypes.byId(archetype.id()).id());
    }
    assertEquals(archetypes.size(), catalog.bundle().archetypes().size());
  }

  @Test
  @DisplayName("every motto belongs to an archetype that exists")
  void mottosPointAtRealArchetypes() {
    Set<String> ids =
        catalog.bundle().archetypes().stream()
            .map(archetype -> archetype.id())
            .collect(Collectors.toCollection(HashSet::new));

    for (var motto : catalog.bundle().mottos()) {
      assertTrue(ids.contains(motto.archetypeId()), motto.id() + " points nowhere");
    }
  }

  @Test
  @DisplayName("the version is derived, so nobody has to remember to bump it")
  void versionIsStableAndDerived() {
    assertEquals(catalog.bundle().version(), catalog.version());
    assertEquals(12, catalog.bundle().version().length());
  }

  @Test
  @DisplayName("ids are unique, or a lookup would pick one of two")
  void idsAreUnique() {
    assertEquals(
        catalog.bundle().mottos().size(),
        catalog.bundle().mottos().stream().map(motto -> motto.id()).distinct().count(),
        "motto ids");
    assertEquals(
        catalog.bundle().connectors().size(),
        catalog.bundle().connectors().stream().map(connector -> connector.id()).distinct().count(),
        "connector ids");
  }
}
