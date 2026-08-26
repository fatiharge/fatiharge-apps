package com.dafalabs.api.auth.device;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;
import static org.junit.jupiter.api.Assertions.assertEquals;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class DeviceRegistrationTest {

  private static final String REGISTER = "/v1/devices/register";
  private static final String ME = "/v1/devices/me";

  @Test
  @DisplayName("a first registration returns an identity and a token")
  void registersANewDevice() {
    given()
        .contentType(ContentType.JSON)
        .body(body(hashOf("first-device"), "ios"))
        .when()
        .post(REGISTER)
        .then()
        .statusCode(200)
        .body("deviceId", not(equalTo(null)))
        .body("token", not(equalTo("")))
        .body("expiresInSeconds", equalTo(3600));
  }

  @Test
  @DisplayName("registering again reuses the identity instead of creating another")
  void reregistrationKeepsTheSameIdentity() {
    String hash = hashOf("returning-device");

    String first = register(hash);
    String second = register(hash);

    assertEquals(first, second);
  }

  @Test
  @DisplayName("a hash that is not a SHA-256 is refused by its own code")
  void refusesAMalformedHash() {
    given()
        .contentType(ContentType.JSON)
        .body(body("not-a-hash", "ios"))
        .when()
        .post(REGISTER)
        .then()
        .statusCode(400)
        .body("code", equalTo("invalid_device_hash"));
  }

  @Test
  @DisplayName("an unknown platform is refused by its own code")
  void refusesAnUnknownPlatform() {
    given()
        .contentType(ContentType.JSON)
        .body(body(hashOf("windows-phone"), "windows"))
        .when()
        .post(REGISTER)
        .then()
        .statusCode(400)
        .body("code", equalTo("invalid_platform"));
  }

  @Test
  @DisplayName("the issued token resolves back to the device that was registered")
  void tokenResolvesToItsDevice() {
    String hash = hashOf("token-holder");
    var registration =
        given()
            .contentType(ContentType.JSON)
            .body(body(hash, "android"))
            .when()
            .post(REGISTER)
            .then()
            .statusCode(200)
            .extract();

    given()
        .header("Authorization", "Bearer " + registration.path("token").toString())
        .when()
        .get(ME)
        .then()
        .statusCode(200)
        .body("deviceId", equalTo(registration.path("deviceId").toString()));
  }

  @Test
  @DisplayName("no token is a 401, not a 500 — the catch-all must not swallow it")
  void missingTokenIsRejected() {
    given().when().get(ME).then().statusCode(401);
  }

  @Test
  @DisplayName("a token nobody signed is a 401")
  void forgedTokenIsRejected() {
    given()
        .header("Authorization", "Bearer not.a.token")
        .when()
        .get(ME)
        .then()
        .statusCode(401);
  }

  private static String register(String hash) {
    return given()
        .contentType(ContentType.JSON)
        .body(body(hash, "ios"))
        .when()
        .post(REGISTER)
        .then()
        .statusCode(200)
        .extract()
        .path("deviceId");
  }

  private static String body(String deviceHash, String platform) {
    return "{\"deviceHash\":\"%s\",\"platform\":\"%s\"}".formatted(deviceHash, platform);
  }

  /** The app hashes on the phone; the tests do the same so the input is real. */
  private static String hashOf(String seed) {
    try {
      MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
      return HexFormat.of().formatHex(sha256.digest(seed.getBytes(StandardCharsets.UTF_8)));
    } catch (NoSuchAlgorithmException impossible) {
      throw new IllegalStateException(impossible);
    }
  }
}
