package com.dafalabs.api.motto.content;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import com.dafalabs.api.motto.admin.GivenContent;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.RuleRow;
import com.dafalabs.api.motto.content.write.ArchetypeWrite;
import com.dafalabs.api.motto.content.write.ContentWriter;
import com.dafalabs.api.motto.scoring.ArchetypeCatalog;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.quarkus.test.security.jwt.Claim;
import io.quarkus.test.security.jwt.JwtSecurity;
import com.dafalabs.api.motto.scoring.Dimension;
import jakarta.inject.Inject;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The same product, read in two languages.
 *
 * <p>What is being pinned down here is the seam rather than the sentences: a
 * request says which language it wants, a language nobody has written yet is
 * answered rather than refused, and the two never get confused for each other
 * by a cache.
 */
@QuarkusTest
class SecondLanguageTest {

  private static final String DEVICE = "33333333-3333-3333-3333-333333333333";

  @Inject ContentCatalog catalog;
  @Inject ArchetypeCatalog catalogue;
  @Inject ContentWriter writer;
  @Inject ContentStore store;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("an English phone reads English once somebody has written it")
  void answersInEnglish() {
    given.alsoInEnglish();

    given()
        .header("Accept-Language", "en-GB,en;q=0.9")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body(nameOf(GivenContent.ARCHETYPE), equalTo("Archetype " + GivenContent.ARCHETYPE))
        .body("skeletons.find { it.day == 1 }.title", equalTo("Day 1"));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("and a Turkish one still reads Turkish")
  void stillAnswersInTurkish() {
    given.alsoInEnglish();

    given()
        .header("Accept-Language", "tr-TR,tr;q=0.9")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body(nameOf(GivenContent.ARCHETYPE), equalTo("Arketip " + GivenContent.ARCHETYPE));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a language nobody has written is answered rather than left blank")
  void fallsBackWholesale() {
    given.forgetEnglish();

    // A phone set to English gets the Turkish package whole, because a package
    // with no archetypes is a phone with nothing on the screen and no way to
    // say why.
    given()
        .header("Accept-Language", "en")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body("version", equalTo(catalog.bundle("tr").version()))
        .body(nameOf(GivenContent.ARCHETYPE), equalTo("Arketip " + GivenContent.ARCHETYPE));
  }

  /// Addressed by id rather than by position: the test database is shared, and
  /// another class's archetype is not this test's business.
  private static String nameOf(String archetype) {
    return "archetypes.find { it.id == '%s' }.name".formatted(archetype);
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("a language the server has never heard of is answered too")
  void fallsBackForAnUnknownLanguage() {
    given()
        .header("Accept-Language", "de-DE,de;q=0.9")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body("version", equalTo(catalog.bundle("tr").version()));
  }

  @Test
  @DisplayName("the two packages are two versions, so no cache serves one for the other")
  void versionsDiffer() {
    given.alsoInEnglish();

    ContentBundle turkish = catalog.bundle("tr");
    ContentBundle english = catalog.bundle("en");

    // Same ids, same shape, different sentences. If the version were over the
    // row count these would match, and a phone that changed language would be
    // told it was already up to date.
    assertNotEquals(turkish.version(), english.version());
    assertEquals(
        turkish.archetypes().stream().anyMatch(a -> a.id().equals(GivenContent.ARCHETYPE)),
        english.archetypes().stream().anyMatch(a -> a.id().equals(GivenContent.ARCHETYPE)));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("the version an English phone holds is not the Turkish one")
  void doesNotAnswer304AcrossLanguages() {
    given.alsoInEnglish();

    given()
        .header("If-None-Match", "\"" + catalog.bundle("tr").version() + "\"")
        .header("Accept-Language", "en")
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .body("version", not(equalTo(catalog.bundle("tr").version())));
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("the same answers give the same archetype in either language")
  void scoringIsLanguageBlind() {
    given.alsoInEnglish();

    Map<String, Object> answers = new LinkedHashMap<>();
    for (Dimension dimension : Dimension.values()) {
      String letter = dimension.name().substring(0, 1).toLowerCase(Locale.ROOT);
      for (int index = 1; index <= 4; index++) {
        answers.put(letter + index, 5);
      }
    }
    Map<String, Object> submission = Map.of("answers", answers, "spendSkip", false);

    String turkish = archetypeFrom(submission, "tr");
    String english = archetypeFrom(submission, "en");

    // The words are translated; the instrument is not. A dimension or a
    // reverse flag read from whichever language the phone happens to be set to
    // would let a translator change who gets which archetype.
    assertEquals(turkish, english);
  }

  private static String archetypeFrom(Map<String, Object> submission, String language) {
    return given()
        .contentType("application/json")
        .header("Accept-Language", language)
        .body(submission)
        .when()
        .post("/v1/tests/partial")
        .then()
        .statusCode(200)
        .extract()
        .path("id");
  }

  @Test
  @DisplayName("a translation cannot move where an archetype sits")
  void aTranslationDoesNotTouchTheRules() {
    String before = rulesAsText();

    // The same ids, with the points deliberately wrong and every archetype on
    // top of every other. Taken as rules, this would be refused by the
    // reachability gate; taken as a translation, it is only sentences.
    List<ArchetypeWrite> shoved = new ArrayList<>();
    int ordinal = 1;
    for (String id : GivenContent.ARCHETYPES.keySet()) {
      shoved.add(
          new ArchetypeWrite(
              id,
              "Archetype " + id,
              "Someone who is %s. The cost is that this line was written for a test."
                  .formatted(id),
              "%s motto in English".formatted(id),
              ordinal++,
              List.of("openness"),
              Map.of(
                  "openness", 0.5,
                  "conscientiousness", 0.5,
                  "extraversion", 0.5,
                  "agreeableness", 0.5,
                  "neuroticism", 0.5)));
    }
    writer.archetypes(GivenContent.ENGLISH, shoved);

    // The words changed; where anybody lands did not.
    assertEquals(before, rulesAsText());
    assertEquals(
        "Archetype " + GivenContent.ARCHETYPE,
        catalogue.all(GivenContent.ENGLISH).get(GivenContent.ARCHETYPE).name());
  }

  private String rulesAsText() {
    return store.rules().stream()
        .sorted(java.util.Comparator.comparing(RuleRow::archetypeId))
        .map(row -> "%s %s %s".formatted(row.archetypeId(), row.defining(), row.target()))
        .toList()
        .toString();
  }

  @Test
  @TestSecurity(user = DEVICE)
  @JwtSecurity(claims = @Claim(key = "sub", value = DEVICE))
  @DisplayName("the answer says it varies by language, so a proxy cannot mix them")
  void saysItVaries() {
    given()
        .when()
        .get("/v1/content")
        .then()
        .statusCode(200)
        .header("Vary", "Accept-Language");
  }
}
