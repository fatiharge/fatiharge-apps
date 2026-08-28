package com.dafalabs.api.motto.admin;

import static io.restassured.RestAssured.given;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * With no token configured — the default everywhere, including any deployment
 * that forgets the variable — the door is shut rather than open.
 */
@QuarkusTest
class AdminIsClosedByDefaultTest {

  @Test
  @DisplayName("no token configured means nobody gets in, not everybody")
  void failsClosed() {
    given()
        .header(AdminTokenFilter.HEADER, "anything")
        .when()
        .get("/admin/content/unwritten")
        .then()
        .statusCode(404);
  }
}
