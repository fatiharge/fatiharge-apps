package com.dafalabs.api.motto.entitlement;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.Mockito.when;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.quarkus.test.security.jwt.Claim;
import io.quarkus.test.security.jwt.JwtSecurity;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The clock is mocked rather than waited on: a cooldown test that reads the wall
 * clock either takes two weeks or proves nothing.
 */
@QuarkusTest
class EntitlementTest {

  private static final String DEVICE = "11111111-1111-1111-1111-111111111111";
  private static final Instant START = Instant.parse("2026-01-01T09:00:00Z");

  @InjectMock Clock clock;

  @BeforeEach
  void fixTime() {
    at(START);
  }

  private void at(Instant moment) {
    when(clock.instant()).thenReturn(moment);
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a device that has never asked has its free uses and no cooldown")
  void startsWithFreeUses() {
    given()
        .when()
        .get("/v1/entitlements")
        .then()
        .statusCode(200)
        .body("remainingUses", equalTo(2))
        .body("cooldownUntil", nullValue())
        .body("skipsLeft", equalTo(1))
        .body("premium", equalTo(false));
  }

  @Test
  @DisplayName("without a token there is nothing to answer")
  void refusesTheUnauthenticated() {
    given().when().get("/v1/entitlements").then().statusCode(401);
  }

  @Test
  @TestSecurity(user = "22222222-2222-2222-2222-222222222222")
  @JwtSecurity(claims = @Claim(key = "sub", value = "22222222-2222-2222-2222-222222222222"))
  @DisplayName("deleting data does not hand the free uses back")
  void deletionKeepsTheCounter() {
    // Spend one, so there is something the deletion could plausibly reset.
    entitlements().spendUse(java.util.UUID.fromString("22222222-2222-2222-2222-222222222222"), false);

    given()
        .when()
        .delete("/v1/me")
        .then()
        .statusCode(200)
        .body("kept", org.hamcrest.Matchers.hasItem("usage_counter"));

    given()
        .when()
        .get("/v1/entitlements")
        .then()
        .statusCode(200)
        .body("remainingUses", equalTo(1));
  }

  @Test
  @TestSecurity(user = "33333333-3333-3333-3333-333333333333")
  @JwtSecurity(claims = @Claim(key = "sub", value = "33333333-3333-3333-3333-333333333333"))
  @DisplayName("the cooldown starts when a use is spent and ends on its own")
  void cooldownRunsAndExpires() {
    var device = java.util.UUID.fromString("33333333-3333-3333-3333-333333333333");

    entitlements().spendUse(device, false);

    given()
        .when()
        .get("/v1/entitlements")
        .then()
        .body("remainingUses", equalTo(1))
        .body("cooldownUntil", notNullValue());

    at(START.plus(Duration.ofDays(14)).plusSeconds(1));

    given().when().get("/v1/entitlements").then().body("cooldownUntil", nullValue());
  }

  private Entitlements entitlements() {
    return io.quarkus.arc.Arc.container().instance(Entitlements.class).get();
  }
}
