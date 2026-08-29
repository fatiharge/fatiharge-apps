package com.dafalabs.api.motto.admin;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.TestProfile;
import io.quarkus.test.junit.QuarkusTestProfile;
import io.restassured.http.ContentType;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
@TestProfile(ContentAdminResourceTest.WithAToken.class)
class ContentAdminResourceTest {

  public static class WithAToken implements QuarkusTestProfile {
    @Override
    public Map<String, String> getConfigOverrides() {
      return Map.of("motto.admin.token", "open-sesame");
    }
  }

  private static final String TOKEN = "open-sesame";

  @Test
  @DisplayName("without the token it does not admit to existing")
  void theDoorIsShut() {
    given()
        .contentType(ContentType.JSON)
        .body(List.of())
        .when()
        .put("/admin/content/tasks")
        .then()
        .statusCode(404);

    given()
        .header(AdminTokenFilter.HEADER, "wrong")
        .contentType(ContentType.JSON)
        .body(List.of())
        .when()
        .put("/admin/content/tasks")
        .then()
        .statusCode(404);
  }

  @Test
  @DisplayName("a task is written, and writing it again changes nothing")
  void tasksUpsert() {
    var task =
        Map.of(
            "day", 3,
            "archetypeId", "quiet_builder",
            "ordinal", 2,
            "title", "Bir dakikanı seç",
            "detail", "Bugün yapacağın şeyi seç.",
            "placeholder", false);

    for (var attempt = 0; attempt < 2; attempt++) {
      given()
          .header(AdminTokenFilter.HEADER, TOKEN)
          .contentType(ContentType.JSON)
          .body(List.of(task))
          .when()
          .put("/admin/content/tasks")
          .then()
          .statusCode(200)
          .body("written", equalTo(1));
    }
  }

  @Test
  @DisplayName("report pieces upsert on the slots that identify them, nulls included")
  void reportPiecesUpsert() {
    var piece =
        new java.util.HashMap<String, Object>(
            Map.of("kind", "reading", "dimension", "OPENNESS", "band", "low", "text", "Yeni "
                + "olana temkinli yaklaşıyorsun.", "placeholder", false));
    piece.put("archetypeId", null);
    piece.put("section", null);

    for (var attempt = 0; attempt < 2; attempt++) {
      given()
          .header(AdminTokenFilter.HEADER, TOKEN)
          .contentType(ContentType.JSON)
          .body(List.of(piece))
          .when()
          .put("/admin/content/report-pieces")
          .then()
          .statusCode(200)
          .body("written", equalTo(1));
    }
  }

  @Test
  @DisplayName("what is still unwritten can be asked for")
  void unwrittenIsAQuestion() {
    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .when()
        .get("/admin/content/unwritten")
        .then()
        .statusCode(200)
        .body("tasks", equalTo(0));
  }

  /**
   * Writes the last section the report actually has.
   *
   * <p>The table used to allow four and the report grew a fifth, and nothing
   * caught it: content is tested through the classpath and the fixture, and
   * neither of those goes near an INSERT. A check constraint is only real on
   * the way into the database, so this test has to take that road.
   */
  @Test
  @DisplayName("a piece in the report's last section reaches the table")
  void theLastSectionIsWritable() {
    var piece =
        new java.util.HashMap<String, Object>(
            Map.of(
                "kind", "fragment",
                "archetypeId", "quiet_builder",
                "section", 5,
                "text", "Bölümün son parçası.",
                "placeholder", false));
    piece.put("dimension", null);
    piece.put("band", null);

    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .contentType(ContentType.JSON)
        .body(List.of(piece))
        .when()
        .put("/admin/content/report-pieces")
        .then()
        .statusCode(200)
        .body("written", equalTo(1));
  }

  /**
   * The archetype endpoint, over HTTP rather than through the bean.
   *
   * <p>The gates that make the tables safe to hand somebody live in the write
   * path, and the write path is only reachable through this door. A test that
   * calls the bean proves the gate; only this one proves the door is wired to
   * it — and that a refusal comes back as a refusal rather than a 500.
   */
  @Test
  @DisplayName("an archetype is written, and writing it again changes nothing")
  void archetypesUpsert() {
    for (var attempt = 0; attempt < 2; attempt++) {
      given()
          .header(AdminTokenFilter.HEADER, TOKEN)
          .contentType(ContentType.JSON)
          .body(List.of(archetype("far_corner", "Uzak Köşe", 0.05)))
          .when()
          .put("/admin/content/archetypes")
          .then()
          .statusCode(200)
          .body("written", equalTo(1));
    }
  }

  @Test
  @DisplayName("an archetype too close to another is refused with its own code")
  void tooCloseIsRefused() {
    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .contentType(ContentType.JSON)
        .body(List.of(archetype("far_corner", "Uzak Köşe", 0.05)))
        .when()
        .put("/admin/content/archetypes")
        .then()
        .statusCode(200);

    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .contentType(ContentType.JSON)
        .body(List.of(archetype("far_corner_twin", "İkiz Köşe", 0.06)))
        .when()
        .put("/admin/content/archetypes")
        .then()
        .statusCode(400)
        .body("code", equalTo("archetype_unreachable"));
  }

  @Test
  @DisplayName("guideline 1.4.1 words are refused at the door")
  void forbiddenWordsAreRefused() {
    var clinical =
        Map.of(
            "id", "clinician",
            "name", "Teşhis Koyan",
            "summary", "Kişilik testi sonucun bu.",
            "motto", "Ölç ve söyle.",
            "ordinal", 90,
            "defining", List.of("openness"),
            "target", target(0.05));

    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .contentType(ContentType.JSON)
        .body(List.of(clinical))
        .when()
        .put("/admin/content/archetypes")
        .then()
        .statusCode(400)
        .body("code", equalTo("forbidden_words"));
  }

  @Test
  @DisplayName("the package a phone would be sent can be read from here")
  void theBundleIsReadable() {
    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .when()
        .get("/admin/content/bundle")
        .then()
        .statusCode(200)
        .body("version.size()", equalTo(12))
        .body("skeletons.size()", equalTo(14));
  }

  /**
   * Guideline 1.4.1, backwards over every row already there.
   *
   * <p>The gate only sees what comes through the door, and rows do get
   * corrected at a psql prompt. This is the sweep that catches those — and
   * running it here means the seeded content is checked on every build.
   */
  @Test
  @DisplayName("nothing already in the tables trips the word table")
  void nothingSeededIsObjectionable() {
    given()
        .header(AdminTokenFilter.HEADER, TOKEN)
        .when()
        .get("/admin/content/objections")
        .then()
        .statusCode(200)
        .body("size()", equalTo(0));
  }

  /// A corner far enough from the eighteen that it is reachable, parameterised
  /// on openness so a second one can be placed next to it.
  private static Map<String, Object> archetype(String id, String name, double openness) {
    return Map.of(
        "id", id,
        "name", name,
        "summary", "Kimsenin durmadığı yerde duruyorsun. Bedeli, oradan geçen olmaması.",
        "motto", "Kendi köşemdeyim.",
        "ordinal", 91,
        "defining", List.of("openness", "neuroticism"),
        "target", target(openness));
  }

  private static Map<String, Object> target(double openness) {
    return Map.of(
        "openness", openness,
        "conscientiousness", 0.05,
        "extraversion", 0.95,
        "agreeableness", 0.05,
        "neuroticism", 0.05);
  }
}
