package com.dafalabs.api.motto.admin;

import static io.restassured.RestAssured.given;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.QuarkusTestProfile;
import io.quarkus.test.junit.TestProfile;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The reset with the token but without the switch — which is exactly what
 * production is, and what any deployment that forgets the variable is.
 */
@QuarkusTest
@TestProfile(DeviceResetTest.TokenButNoSwitch.class)
class DeviceResetTest {

  public static class TokenButNoSwitch implements QuarkusTestProfile {
    @Override
    public Map<String, String> getConfigOverrides() {
      return Map.of("motto.admin.token", "open-sesame");
    }
  }

  @Test
  @DisplayName("a right token is not enough: without the switch it is not there")
  void theSwitchIsSeparate() {
    given()
        .header(AdminTokenFilter.HEADER, "open-sesame")
        .when()
        .delete("/admin/content/devices?confirm=" + DeviceReset.CONFIRMATION)
        .then()
        .statusCode(404);
  }
}
