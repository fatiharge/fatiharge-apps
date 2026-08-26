package com.dafalabs.api.motto;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class HealthTest {

  /**
   * There is nothing to serve yet, so what this proves is the part that matters
   * before the first deployment: the service starts, reaches its database and
   * says so through the endpoint the deploy will be judged by.
   */
  @Test
  @DisplayName("the service reports healthy, database included")
  void reportsHealthy() {
    given()
        .when()
        .get("/q/health")
        .then()
        .statusCode(200)
        .body("status", equalTo("UP"))
        .body(
            "checks.find { it.name == 'Database connections health check' }.status",
            equalTo("UP"));
  }
}
