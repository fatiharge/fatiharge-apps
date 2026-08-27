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
 * The package the app ships with has to agree with the one the server serves.
 *
 * <p>Not a style point: they are stamped with the same version, so a mismatch
 * means every first launch downloads a package it already has — silently, and
 * for as long as nobody notices.
 */
@QuarkusTest
class BundledAssetTest {

  private static final Path ASSET =
      Path.of("../../apps/motto/assets/content/bundle.json");

  @Inject ContentCatalog catalog;

  @Test
  @DisplayName("the bundled asset carries the version the server would serve")
  void versionsAgree() throws IOException {
    JsonNode asset = new ObjectMapper().readTree(Files.readString(ASSET));

    // Regenerate with scripts/bundle_content.py after editing anything in
    // content/, and commit the result.
    assertEquals(
        catalog.bundle().version(),
        asset.get("version").asText(),
        "run scripts/bundle_content.py and commit apps/motto/assets/content/bundle.json");
  }

  @Test
  @DisplayName("and the same pieces")
  void contentsAgree() throws IOException {
    JsonNode asset = new ObjectMapper().readTree(Files.readString(ASSET));

    assertEquals(catalog.bundle().archetypes().size(), asset.get("archetypes").size());
    assertEquals(catalog.bundle().mottos().size(), asset.get("mottos").size());
    assertEquals(catalog.bundle().skeletons().size(), asset.get("skeletons").size());
    assertEquals(catalog.bundle().fragments().size(), asset.get("fragments").size());
    assertEquals(catalog.bundle().connectors().size(), asset.get("connectors").size());
  }
}
