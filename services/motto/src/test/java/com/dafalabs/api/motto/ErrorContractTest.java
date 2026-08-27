package com.dafalabs.api.motto;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.emptyOrNullString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The error contract from the outside, over HTTP.
 *
 * <p>{@code ErrorPayloadsTest} already proves what the body should say. What
 * this adds is that it actually reaches the wire — and its {@code IT} subclass
 * proves the same against the native binary, where a body that is never
 * registered for reflection fails to serialise and the caller gets the
 * framework's own error page instead of anything in this contract.
 */
@QuarkusTest
class ErrorContractTest {

  @Test
  @DisplayName("an unknown path answers 404 in the error contract")
  void unknownPathKeepsItsStatus() {
    given()
        .when()
        .get("/v1/nope")
        .then()
        .statusCode(404)
        .contentType(ContentType.JSON)
        .body("code", equalTo("not_found"))
        .body("traceId", not(emptyOrNullString()));
  }

  @Test
  @DisplayName("a request with no token answers 401, not 500")
  void missingTokenIsRejectedNotBroken() {
    given().when().get("/v1/entitlements").then().statusCode(401);
  }
}
