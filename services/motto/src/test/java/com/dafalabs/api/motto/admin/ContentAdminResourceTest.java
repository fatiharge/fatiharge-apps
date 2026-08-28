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
}
