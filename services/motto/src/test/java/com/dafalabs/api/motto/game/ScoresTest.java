package com.dafalabs.api.motto.game;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.entitlement.Entitlements;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ScoresTest {

  /// A Wednesday, so the week it belongs to is not the day itself.
  private static final LocalDate TODAY = LocalDate.of(2026, 3, 11);

  @Inject Scores scores;
  @Inject Entitlements entitlements;
  @InjectMock Clock clock;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    at(TODAY);
  }

  private void at(LocalDate day) {
    when(clock.instant()).thenReturn(day.atStartOfDay(ZoneOffset.UTC).toInstant());
    when(clock.getZone()).thenReturn(ZoneOffset.UTC);
    when(clock.withZone(ZoneOffset.UTC))
        .thenReturn(Clock.fixed(day.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC));
  }

  @Test
  @DisplayName("a week is the Monday it started on")
  void weeksStartOnMonday() {
    assertEquals(LocalDate.of(2026, 3, 9), Scores.weekOf(TODAY));
    assertEquals(LocalDate.of(2026, 3, 9), Scores.weekOf(LocalDate.of(2026, 3, 9)));
    assertEquals(LocalDate.of(2026, 3, 9), Scores.weekOf(LocalDate.of(2026, 3, 15)));
  }

  @Test
  @DisplayName("a score goes on the board, and the reader can find their own line")
  void aScoreIsRecorded() {
    var board = scores.record(device, 120);

    assertEquals(120, board.yourBest());
    assertTrue(board.entries().stream().anyMatch(entry -> entry.you()));
  }

  @Test
  @DisplayName("a number the game cannot produce is refused")
  void refusesAnImpossibleScore() {
    assertEquals(
        "impossible_score",
        assertThrows(
                CustomRuntimeException.class,
                () -> scores.record(device, Scores.impossiblePoints + 1))
            .code());
  }

  @Test
  @DisplayName("one line per device, however many times they play")
  void oneLinePerDevice() {
    scores.record(device, 50);
    scores.record(device, 90);
    var board = scores.record(device, 70);

    // A board where somebody holds three of the top ten is a board nobody
    // else plays.
    assertEquals(1, board.entries().stream().filter(entry -> entry.you()).count());
    assertEquals(90, board.yourBest());
  }

  @Test
  @DisplayName("the week's best are ordered, highest first")
  void theBoardIsOrdered() {
    scores.record(UUID.randomUUID(), 10);
    scores.record(UUID.randomUUID(), 300);
    var board = scores.record(device, 100);

    var points = board.entries().stream().map(entry -> entry.points()).toList();
    assertEquals(points.stream().sorted(java.util.Comparator.reverseOrder()).toList(), points);
  }

  @Test
  @DisplayName("the finished week pays its best, and pays them once")
  void awardingIsIdempotent() {
    // Its own week: the tests share a database, and a week other cases have
    // played in would count their devices too.
    var day = LocalDate.of(2026, 6, 10);
    at(day);
    var week = Scores.weekOf(day);
    scores.record(device, 200);
    assertFalse(entitlements.stateOf(device).premium());

    assertEquals(1, scores.awardWeek(week));
    assertTrue(entitlements.stateOf(device).premium());

    // A redeploy or a retry must not hand the same ten a second report each.
    assertEquals(0, scores.awardWeek(week));
  }

  @Test
  @DisplayName("a week nobody played settles without paying anyone")
  void anEmptyWeekSettles() {
    assertEquals(0, scores.awardWeek(Scores.weekOf(TODAY).minusWeeks(4)));
  }
}
