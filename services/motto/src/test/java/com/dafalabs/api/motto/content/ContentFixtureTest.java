package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The fixture the app's tests read has to be a package this service could send.
 *
 * <p>Not the same one. It is pulled from a running server — the words live in
 * that server's database — so two environments can honestly hold different
 * sentences and a version check here would only ever fail for that reason.
 * What has to hold is the shape: every field the client reads, filled, and no
 * fragment pointing at an archetype the app cannot name.
 */
@QuarkusTest
class ContentFixtureTest {

  private static final Path FIXTURE =
      Path.of("../../apps/motto/test/fixtures/content_bundle.json");

  @Inject ContentCatalog catalog;

  @Test
  @DisplayName("the fixture is a package this service could serve")
  void theFixtureIsWellFormed() throws IOException {
    JsonNode fixture = new ObjectMapper().readTree(Files.readString(FIXTURE));
    JsonNode live = new ObjectMapper().valueToTree(catalog.bundle());

    Set<String> fields = new HashSet<>();
    fixture.fieldNames().forEachRemaining(fields::add);
    Set<String> expected = new HashSet<>();
    live.fieldNames().forEachRemaining(expected::add);
    assertEquals(expected, fields, "run scripts/content_fixture.py and commit the result");

    assertEquals(12, fixture.get("version").asText().length());
    assertEquals(14, fixture.get("skeletons").size());
    for (String list : expected) {
      if (fixture.get(list).isArray()) {
        assertFalse(fixture.get(list).isEmpty(), list + " is empty");
      }
    }

    Set<String> archetypes = new HashSet<>();
    fixture.get("archetypes").forEach(node -> archetypes.add(node.get("id").asText()));
    for (JsonNode fragment : fixture.get("fragments")) {
      assertTrue(
          archetypes.contains(fragment.get("archetypeId").asText()),
          fragment.get("archetypeId").asText() + " has no archetype");
    }
  }
}
