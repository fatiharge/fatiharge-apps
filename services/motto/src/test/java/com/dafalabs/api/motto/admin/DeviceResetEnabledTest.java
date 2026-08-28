package com.dafalabs.api.motto.admin;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.result.Result;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.QuarkusTestProfile;
import io.quarkus.test.junit.TestProfile;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
@TestProfile(DeviceResetEnabledTest.SwitchedOn.class)
class DeviceResetEnabledTest {

  public static class SwitchedOn implements QuarkusTestProfile {
    @Override
    public Map<String, String> getConfigOverrides() {
      return Map.of("motto.admin.token", "open-sesame", "motto.admin.reset-enabled", "true");
    }
  }

  @Inject Results results;
  @Inject GivenContent content;

  @Transactional
  UUID givenADeviceWithAResult() {
    UUID device = UUID.randomUUID();
    Map<Dimension, Double> scores = new EnumMap<>(Dimension.class);
    for (Dimension dimension : Dimension.values()) {
      scores.put(dimension, 0.5);
    }
    results.record(device, "quiet_builder", new ProfileVector(scores));
    return device;
  }

  @Test
  @DisplayName("without the confirmation it refuses, and says what to say")
  void meaningItIsPartOfIt() {
    given()
        .header(AdminTokenFilter.HEADER, "open-sesame")
        .when()
        .delete("/admin/content/devices")
        .then()
        .statusCode(400);
  }

  @Test
  @DisplayName("it forgets every device and keeps every word")
  void contentSurvivesTheWipe() {
    content.everything();
    UUID device = givenADeviceWithAResult();
    assertTrue(hasResults(device));

    given()
        .header(AdminTokenFilter.HEADER, "open-sesame")
        .when()
        .delete("/admin/content/devices?confirm=" + DeviceReset.CONFIRMATION)
        .then()
        .statusCode(200);

    assertEquals(false, hasResults(device));
    // The point of the wipe is a first run, not an empty app.
    given()
        .header(AdminTokenFilter.HEADER, "open-sesame")
        .when()
        .get("/admin/content/unwritten")
        .then()
        .statusCode(200)
        .body("tasks", org.hamcrest.Matchers.equalTo(0));
  }

  @Transactional
  boolean hasResults(UUID device) {
    for (Result result : results.forDevice(device)) {
      if (result != null) {
        return true;
      }
    }
    return false;
  }
}
