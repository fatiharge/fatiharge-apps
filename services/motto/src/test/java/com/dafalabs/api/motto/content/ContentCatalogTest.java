package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.dto.Fragment;
import com.dafalabs.api.motto.scoring.ArchetypeCatalog;
import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ContentCatalogTest {

  @Inject ContentCatalog catalog;
  @Inject ArchetypeCatalog archetypes;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  @Test
  @DisplayName("the package carries every piece a day is made of")
  void carriesEveryPiece() {
    ContentBundle bundle = catalog.bundle("tr");

    // Counted against the archetype table rather than against a number typed
    // here: adding an archetype should fail this test by leaving one of these
    // short, not by disagreeing with a constant somebody forgot to bump.
    int expected = archetypes.size("tr");
    assertEquals(expected, bundle.archetypes().size());
    assertEquals(14, bundle.skeletons().size());
    assertEquals(expected * 14, bundle.fragments().size());
    assertEquals(expected * 4, bundle.mottos().size());
    assertFalse(bundle.connectors().isEmpty());
  }

  @Test
  @DisplayName("every archetype has one fragment per day, or a day repeats")
  void everyArchetypeHasOneFragmentPerDay() {
    Map<String, Long> perArchetype =
        catalog.bundle("tr").fragments().stream()
            .collect(Collectors.groupingBy(Fragment::archetypeId, Collectors.counting()));

    assertEquals(archetypes.size("tr"), perArchetype.size());
    assertTrue(perArchetype.values().stream().allMatch(count -> count == 14L), "" + perArchetype);
  }

  @Test
  @DisplayName("the days are 1 to 14 with none missing")
  void theDaysAreComplete() {
    Set<Integer> days =
        catalog.bundle("tr").skeletons().stream()
            .map(skeleton -> skeleton.day())
            .collect(Collectors.toSet());

    for (int day = 1; day <= 14; day++) {
      assertTrue(days.contains(day), "day " + day + " is missing");
    }
  }

  @Test
  @DisplayName("the words and the scoring rules name the same archetypes")
  void wordsAndRulesAgree() {
    // Two tables, two readers, one truth. This is what it looks like when they
    // stop agreeing — and it looks like a crash at claim time otherwise.
    for (var archetype : catalog.bundle("tr").archetypes()) {
      assertEquals(archetype.id(), archetypes.byId(archetype.id(), "tr").id());
    }
    assertEquals(archetypes.size("tr"), catalog.bundle("tr").archetypes().size());
  }

  @Test
  @DisplayName("every motto belongs to an archetype that exists")
  void mottosPointAtRealArchetypes() {
    Set<String> ids =
        catalog.bundle("tr").archetypes().stream()
            .map(archetype -> archetype.id())
            .collect(Collectors.toCollection(HashSet::new));

    for (var motto : catalog.bundle("tr").mottos()) {
      assertTrue(ids.contains(motto.archetypeId()), motto.id() + " points nowhere");
    }
  }

  @Test
  @DisplayName("the version is derived, so nobody has to remember to bump it")
  void versionIsStableAndDerived() {
    assertEquals(catalog.bundle("tr").version(), catalog.bundle("tr").version());
    assertEquals(12, catalog.bundle("tr").version().length());
  }

  @Test
  @DisplayName("ids are unique, or a lookup would pick one of two")
  void idsAreUnique() {
    assertEquals(
        catalog.bundle("tr").mottos().size(),
        catalog.bundle("tr").mottos().stream().map(motto -> motto.id()).distinct().count(),
        "motto ids");
    assertEquals(
        catalog.bundle("tr").connectors().size(),
        catalog.bundle("tr").connectors().stream().map(connector -> connector.id()).distinct().count(),
        "connector ids");
  }
}
