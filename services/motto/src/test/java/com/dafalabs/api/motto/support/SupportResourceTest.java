package com.dafalabs.api.motto.support;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.greaterThan;

import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.quarkus.test.security.jwt.Claim;
import io.quarkus.test.security.jwt.JwtSecurity;
import jakarta.inject.Inject;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class SupportResourceTest {

  private static final String DEVICE = "33333333-3333-3333-3333-333333333333";

  @Inject SupportCatalog catalog;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("the copy arrives whole, with a version to send back")
  void servesTheCopy() {
    given()
        .when()
        .get("/v1/support")
        .then()
        .statusCode(200)
        .body("version", equalTo(catalog.copy().version()))
        .body("faq.size()", Matchers.greaterThan(11))
        .body("privacy.size()", greaterThan(0));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a client that is up to date gets nothing back")
  void answers304() {
    given()
        .header("If-None-Match", "\"" + catalog.copy().version() + "\"")
        .when()
        .get("/v1/support")
        .then()
        .statusCode(304);
  }

  @Test
  @DisplayName("without a token there is no copy")
  void requiresAToken() {
    given().when().get("/v1/support").then().statusCode(401);
  }
}
