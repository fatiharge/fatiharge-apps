package com.dafalabs.api.motto.content;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;

import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.quarkus.test.security.jwt.Claim;
import io.quarkus.test.security.jwt.JwtSecurity;
import jakarta.inject.Inject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ContentResourceTest {

  private static final String DEVICE = "22222222-2222-2222-2222-222222222222";

  @Inject ContentCatalog catalog;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("the package arrives whole, with a version to send back")
  void servesTheWholePackage() {
    given()
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .header("ETag", notNullValue())
        .body("version", equalTo(catalog.bundle().version()))
        .body("skeletons", hasSize(14))
        .body("fragments", hasSize(catalog.bundle().fragments().size()));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a client that is up to date gets nothing back")
  void answers304WhenNothingChanged() {
    // This package is most of what the app downloads and it changes when
    // somebody edits a sentence — which is rarely.
    given()
        .header("If-None-Match", "\"" + catalog.bundle().version() + "\"")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(304);
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a weakly validated tag still counts as up to date")
  void acceptsAWeakTag() {
    // Some clients and every proxy weaken the tag. Comparing the raw string
    // would answer 200 to a client that is already current, every time.
    given()
        .header("If-None-Match", "W/\"" + catalog.bundle().version() + "\"")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(304);
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("an old version gets the whole package again")
  void servesAgainWhenTheVersionMoved() {
    given()
        .header("If-None-Match", "\"000000000000\"")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body("version", equalTo(catalog.bundle().version()));
  }

  @Test
  @DisplayName("without a token there is no package")
  void requiresAToken() {
    given().when().get("/v1/content").then().statusCode(401);
  }
}
