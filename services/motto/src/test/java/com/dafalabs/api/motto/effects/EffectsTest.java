package com.dafalabs.api.motto.effects;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.dafalabs.api.core.error.CustomRuntimeException;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class EffectsTest {

  private static final String LOCALE = "tr";

  private static final String SHEET =
      """
      [{"kind":"bottom_sheet","title":"Dogum tarihin gerekiyor",
        "body":"Bir kere sorup bir daha sormayacagim.",
        "choices":[{"label":"Gir","then":[{"kind":"navigate","to":"/dogum-tarihi"}]},
                   {"label":"Simdi degil","then":[]}]}]
      """;

  @Inject Effects effects;

  @Test
  @DisplayName("a definition is read before it is stored")
  void unreadableIsRefused() {
    // A definition the app cannot use is invisible on a phone: the code simply
    // reads as unknown, and whoever wrote it never finds out.
    CustomRuntimeException refused =
        assertThrows(CustomRuntimeException.class, () -> effects.write("x", LOCALE, "not a list"));
    assertEquals("definition_unreadable", refused.code());
  }

  @Test
  @DisplayName("an effect this app has no such thing as is refused")
  void unknownKindIsRefused() {
    CustomRuntimeException refused =
        assertThrows(
            CustomRuntimeException.class,
            () -> effects.write("x", LOCALE, "[{\"kind\":\"launch_missiles\"}]"));
    assertEquals("effect_unknown", refused.code());
  }

  @Test
  @DisplayName("a definition that nests past what the app runs is refused")
  void tooDeepIsRefused() {
    String nested =
        "[{\"kind\":\"sheet\",\"title\":\"a\",\"body\":\"b\",\"choices\":"
            + "[{\"label\":\"x\",\"then\":[{\"kind\":\"sheet\",\"title\":\"c\","
            + "\"body\":\"d\",\"choices\":[{\"label\":\"y\",\"then\":"
            + "[{\"kind\":\"snack\",\"message\":\"z\"}]}]}]}]}]";

    CustomRuntimeException refused =
        assertThrows(CustomRuntimeException.class, () -> effects.write("x", LOCALE, nested));
    assertEquals("definition_too_deep", refused.code());
  }

  @Test
  @DisplayName("editing a sentence changes the version")
  void versionMovesWithTheWords() {
    effects.write("birth_date_required", LOCALE, SHEET);
    String before = effects.catalogue(LOCALE).version();

    effects.write("birth_date_required", LOCALE, SHEET.replace("Gir", "Girelim"));

    // A phone holding the old one has to be told to come back for it.
    assertNotEquals(before, effects.catalogue(LOCALE).version());
  }
}
