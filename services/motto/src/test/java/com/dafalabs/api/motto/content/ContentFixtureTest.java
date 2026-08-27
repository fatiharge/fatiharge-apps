package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The fixture the app's tests read has to be what this service would send.
 *
 * <p>Nothing ships inside the app any more, but the assembler test still runs
 * against real content — and a fixture that quietly falls behind turns that
 * test into one that proves nothing.
 */
@QuarkusTest
class ContentFixtureTest {

  private static final Path FIXTURE =
      Path.of("../../apps/motto/test/fixtures/content_bundle.json");

  @Inject ContentCatalog catalog;

  @Test
  @DisplayName("the fixture is the package this service would serve")
  void theFixtureIsCurrent() throws IOException {
    JsonNode fixture = new ObjectMapper().readTree(Files.readString(FIXTURE));

    assertEquals(
        catalog.bundle().version(),
        fixture.get("version").asText(),
        "run scripts/content_fixture.py and commit the result");
    assertEquals(catalog.bundle().skeletons().size(), fixture.get("skeletons").size());
    assertEquals(catalog.bundle().fragments().size(), fixture.get("fragments").size());
  }
}
