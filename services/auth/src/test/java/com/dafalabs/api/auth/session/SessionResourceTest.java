package com.dafalabs.api.auth.session;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import com.dafalabs.api.auth.delivery.OutboxRepository;
import com.dafalabs.api.auth.identity.IdentityType;
import com.dafalabs.api.auth.identity.Passwords;
import com.dafalabs.api.auth.identity.Role;
import com.dafalabs.api.auth.identity.User;
import com.dafalabs.api.auth.identity.UserIdentity;
import com.dafalabs.api.auth.identity.UserIdentityRepository;
import com.dafalabs.api.auth.identity.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.narayana.jta.QuarkusTransaction;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import jakarta.inject.Inject;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class SessionResourceTest {

  private static final String CODES = "/v1/auth/codes";
  private static final String BY_CODE = "/v1/auth/sessions/by-code";
  private static final String BY_PASSWORD = "/v1/auth/sessions/by-password";
  private static final String SECOND_FACTOR = "/v1/auth/sessions/second-factor";
  private static final String REFRESH = "/v1/auth/sessions/refresh";
  private static final String ADMIN_PASSWORD = "yonetici-icin-uzun-parola";

  @Inject OutboxRepository outbox;
  @Inject UserRepository users;
  @Inject UserIdentityRepository identities;
  @Inject Passwords passwords;
  @Inject ObjectMapper json;
  @Inject Clock clock;

  @Test
  @DisplayName("an ordinary user signs in with a code, and the account appears on the way")
  void firstCodeSignInCreatesTheAccount() {
    UUID tenant = UUID.randomUUID();
    String address = address();

    String challengeId = requestCode(tenant, address);
    String access = signInWithCode(challengeId, codeSentTo(tenant, address)).get("accessToken").toString();

    assertEquals(tenant.toString(), claim(access, "tenant"));
    assertEquals(Role.USER.name(), claim(access, "role"));
  }

  @Test
  @DisplayName("signing in again finds the account rather than making a second one")
  void repeatSignInReusesTheAccount() {
    UUID tenant = UUID.randomUUID();
    String address = address();

    String first = signInWithCode(requestCode(tenant, address), codeSentTo(tenant, address))
        .get("accessToken").toString();
    String second = signInWithCode(requestCode(tenant, address), codeSentTo(tenant, address))
        .get("accessToken").toString();

    assertEquals(claim(first, "sub"), claim(second, "sub"));
  }

  @Test
  @DisplayName("the same address in two tenants is two unrelated people")
  void oneAddressBecomesTwoAccountsInTwoTenants() {
    UUID firstTenant = UUID.randomUUID();
    UUID secondTenant = UUID.randomUUID();
    String address = address();

    String inFirst = signInWithCode(requestCode(firstTenant, address), codeSentTo(firstTenant, address))
        .get("accessToken").toString();
    String inSecond =
        signInWithCode(requestCode(secondTenant, address), codeSentTo(secondTenant, address))
            .get("accessToken").toString();

    assertNotEquals(claim(inFirst, "sub"), claim(inSecond, "sub"));
    assertEquals(firstTenant.toString(), claim(inFirst, "tenant"));
    assertEquals(secondTenant.toString(), claim(inSecond, "tenant"));
  }

  @Test
  @DisplayName("a code proves an address in one tenant and cannot be spent in another")
  void aCodeCannotBeCarriedToAnotherTenant() {
    UUID firstTenant = UUID.randomUUID();
    String address = address();
    String challengeId = requestCode(firstTenant, address);

    // The tenant is read from the challenge, so naming another one changes nothing:
    // the session that comes back still belongs to the tenant that was proven.
    String access = signInWithCode(challengeId, codeSentTo(firstTenant, address)).get("accessToken").toString();
    assertEquals(firstTenant.toString(), claim(access, "tenant"));
  }

  @Test
  @DisplayName("a wrong code buys nothing")
  void wrongCodeIsRefused() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    String challengeId = requestCode(tenant, address);

    given()
        .contentType(ContentType.JSON)
        .body(Map.of("challengeId", challengeId, "code", "000000"))
        .when()
        .post(BY_CODE)
        .then()
        .statusCode(401)
        .body("code", equalTo("invalid_credentials"));
  }

  @Test
  @DisplayName("a code alone does not open an administrator's account")
  void anAdminCannotSignInWithACodeAlone() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    givenAnAdmin(tenant, address);

    String challengeId = requestCode(tenant, address);
    given()
        .contentType(ContentType.JSON)
        .body(Map.of("challengeId", challengeId, "code", codeSentTo(tenant, address)))
        .when()
        .post(BY_CODE)
        .then()
        .statusCode(409)
        .body("code", equalTo("password_required"));
  }

  @Test
  @DisplayName("an admin's password is the first step, and the code is the second")
  void adminSignInTakesTwoSteps() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    givenAnAdmin(tenant, address);

    Map<String, Object> first = signInWithPassword(tenant, address, ADMIN_PASSWORD);
    assertEquals("SECOND_FACTOR_REQUIRED", first.get("status"));

    String access =
        given()
            .contentType(ContentType.JSON)
            .body(
                Map.of(
                    "pendingToken", first.get("pendingToken"),
                    "code", codeSentTo(tenant, address)))
            .when()
            .post(SECOND_FACTOR)
            .then()
            .statusCode(200)
            .extract()
            .path("accessToken");

    assertEquals(Role.TENANT_ADMIN.name(), claim(access, "role"));
  }

  @Test
  @DisplayName("a wrong password is refused before any code is sent")
  void wrongPasswordSendsNothing() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    givenAnAdmin(tenant, address);

    given()
        .contentType(ContentType.JSON)
        .header(SessionResource.TENANT_HEADER, tenant.toString())
        .body(Map.of("identityType", "EMAIL", "identity", address, "password", "not-the-password"))
        .when()
        .post(BY_PASSWORD)
        .then()
        .statusCode(401);

    assertEquals(0, messagesTo(tenant, address).size());
  }

  @Test
  @DisplayName("a refresh token buys a new session")
  void refreshIssuesANewSession() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    Map<String, Object> session =
        signInWithCode(requestCode(tenant, address), codeSentTo(tenant, address));

    given()
        .contentType(ContentType.JSON)
        .body(Map.of("refreshToken", session.get("refreshToken")))
        .when()
        .post(REFRESH)
        .then()
        .statusCode(200)
        .body("accessToken", not(equalTo(null)));
  }

  @Test
  @DisplayName("an access token is not a refresh token")
  void anAccessTokenCannotRefresh() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    Map<String, Object> session =
        signInWithCode(requestCode(tenant, address), codeSentTo(tenant, address));

    given()
        .contentType(ContentType.JSON)
        .body(Map.of("refreshToken", session.get("accessToken").toString()))
        .when()
        .post(REFRESH)
        .then()
        .statusCode(401);
  }

  @Test
  @DisplayName("blocking someone stops the refresh token already in their hands")
  void blockingEndsEveryLiveSession() {
    UUID tenant = UUID.randomUUID();
    String address = address();
    Map<String, Object> session =
        signInWithCode(requestCode(tenant, address), codeSentTo(tenant, address));

    QuarkusTransaction.requiringNew()
        .run(
            () ->
                identities
                    .find(tenant, IdentityType.EMAIL, address)
                    .flatMap(identity -> users.findByIdOptional(identity.userId()))
                    .orElseThrow()
                    .block());

    given()
        .contentType(ContentType.JSON)
        .body(Map.of("refreshToken", session.get("refreshToken")))
        .when()
        .post(REFRESH)
        .then()
        .statusCode(401);
  }

  @Test
  @DisplayName("a code by phone is refused while nothing carries one")
  void phoneIsRefused() {
    given()
        .contentType(ContentType.JSON)
        .header(SessionResource.TENANT_HEADER, UUID.randomUUID().toString())
        .body(Map.of("identityType", "PHONE", "identity", "+905000000000"))
        .when()
        .post(CODES)
        .then()
        .statusCode(400)
        .body("code", equalTo("channel_unavailable"));
  }

  @Test
  @DisplayName("a request without a tenant is refused")
  void theTenantHeaderIsRequired() {
    given()
        .contentType(ContentType.JSON)
        .body(Map.of("identityType", "EMAIL", "identity", address()))
        .when()
        .post(CODES)
        .then()
        .statusCode(400)
        .body("code", equalTo("invalid_tenant"));
  }

  private String requestCode(UUID tenant, String address) {
    return given()
        .contentType(ContentType.JSON)
        .header(SessionResource.TENANT_HEADER, tenant.toString())
        .body(Map.of("identityType", "EMAIL", "identity", address))
        .when()
        .post(CODES)
        .then()
        .statusCode(200)
        // The code itself must never appear here.
        .body("code", equalTo(null))
        .extract()
        .path("challengeId");
  }

  private Map<String, Object> signInWithCode(String challengeId, String code) {
    return given()
        .contentType(ContentType.JSON)
        .body(Map.of("challengeId", challengeId, "code", code))
        .when()
        .post(BY_CODE)
        .then()
        .statusCode(200)
        .extract()
        .as(Map.class);
  }

  private Map<String, Object> signInWithPassword(UUID tenant, String address, String password) {
    return given()
        .contentType(ContentType.JSON)
        .header(SessionResource.TENANT_HEADER, tenant.toString())
        .body(Map.of("identityType", "EMAIL", "identity", address, "password", password))
        .when()
        .post(BY_PASSWORD)
        .then()
        .statusCode(200)
        .extract()
        .as(Map.class);
  }

  private void givenAnAdmin(UUID tenant, String address) {
    QuarkusTransaction.requiringNew()
        .run(
            () -> {
              User admin = User.create(tenant, Role.TENANT_ADMIN, clock.instant());
              users.persist(admin);
              identities.persist(
                  UserIdentity.claim(admin, IdentityType.EMAIL, address, clock.instant()));
              passwords.set(admin, ADMIN_PASSWORD);
            });
  }

  /** The only place a test can learn a code — the same place a person would. */
  private String codeSentTo(UUID tenant, String address) {
    List<String> payloads = messagesTo(tenant, address);
    try {
      Map<?, ?> variables = json.readValue(payloads.get(0), Map.class);
      return (String) variables.get("code");
    } catch (Exception e) {
      throw new IllegalStateException(e);
    }
  }

  private List<String> messagesTo(UUID tenant, String address) {
    return QuarkusTransaction.requiringNew()
        .call(() -> outbox.to(tenant, address).stream().map(m -> m.variables()).toList());
  }

  private String claim(String jwt, String name) {
    String payload =
        new String(Base64.getUrlDecoder().decode(jwt.split("\\.")[1]), StandardCharsets.UTF_8);
    try {
      return String.valueOf(json.readValue(payload, Map.class).get(name));
    } catch (Exception e) {
      throw new IllegalStateException(e);
    }
  }

  /** A fresh address per test, so the request limits of one do not spend another's. */
  private static String address() {
    return "fan-" + UUID.randomUUID() + "@example.com";
  }
}
