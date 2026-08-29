package com.dafalabs.api.motto.scoring;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ScoringTest {

  @Inject Scoring scoring;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  @Test
  @DisplayName("agreeing with a reverse-coded item counts against its dimension")
  void reverseCodingInverts() {
    var agreeing = scoring.score(Map.of("c3", 5)); // "işleri son ana bırakırım"
    var disagreeing = scoring.score(Map.of("c3", 1));

    assertTrue(agreeing.at(Dimension.CONSCIENTIOUSNESS) < 0.5);
    assertTrue(disagreeing.at(Dimension.CONSCIENTIOUSNESS) > 0.5);
  }

  @Test
  @DisplayName("a dimension nobody answered for sits in the middle, not at zero")
  void unansweredIsUnknownNotLow() {
    var partial = scoring.score(Map.of("e1", 5));

    assertEquals(0.5, partial.at(Dimension.OPENNESS));
  }

  @Test
  @DisplayName("an answer off the scale is refused by its own code")
  void refusesAnswersOffTheScale() {
    var refused =
        assertThrows(CustomRuntimeException.class, () -> scoring.score(Map.of("e1", 9)));

    assertEquals("answer_out_of_range", refused.code());
  }

  @Test
  @DisplayName("an item that does not exist is refused by its own code")
  void refusesUnknownItems() {
    var refused =
        assertThrows(CustomRuntimeException.class, () -> scoring.score(Map.of("nope", 3)));

    assertEquals("unknown_item", refused.code());
  }

  @Test
  @DisplayName("nothing submitted is refused rather than scored as neutral")
  void refusesEmptySubmissions() {
    var refused = assertThrows(CustomRuntimeException.class, () -> scoring.score(Map.of()));

    assertEquals("no_answers", refused.code());
  }
}
