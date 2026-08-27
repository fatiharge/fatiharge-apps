package com.dafalabs.api.motto.chain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import com.dafalabs.api.core.error.CustomRuntimeException;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** The clock is mocked so a day can pass without waiting for one. */
@QuarkusTest
class ChainTest {

  private static final LocalDate TODAY = LocalDate.of(2026, 3, 10);

  @Inject Chains chains;
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
    when(clock.withZone(ZoneOffset.UTC)).thenReturn(Clock.fixed(
        day.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC));
  }

  @Test
  @DisplayName("a device with no chain has nothing, and says so rather than failing")
  void noChainIsAState() {
    var state = chains.state(device, TODAY);

    assertFalse(state.started());
    assertEquals(0, state.streak());
  }

  @Test
  @DisplayName("starting marks today")
  void startingMarksToday() {
    var state = chains.start(device, TODAY);

    assertTrue(state.started());
    assertEquals(1, state.streak());
    assertTrue(state.markedToday());
  }

  @Test
  @DisplayName("marking the same day twice marks it once")
  void markingTwiceIsMarkingOnce() {
    chains.start(device, TODAY);
    var state = chains.mark(device, TODAY, TODAY);

    // The offline queue will send the same day twice sooner or later.
    assertEquals(1, state.streak());
    assertEquals(1, state.markedDays().size());
  }

  @Test
  @DisplayName("the streak survives a chain that survives the app")
  void theStreakAccumulates() {
    chains.start(device, TODAY.minusDays(2));
    chains.mark(device, TODAY.minusDays(1), TODAY);
    var state = chains.mark(device, TODAY, TODAY);

    assertEquals(3, state.streak());
  }

  @Test
  @DisplayName("the make-up fills the missed day and cannot be spent twice")
  void theMakeUpIsMonthly() {
    chains.start(device, TODAY.minusDays(2));
    var state = chains.state(device, TODAY);
    assertTrue(state.broken());
    assertTrue(state.canFreeze());

    var after = chains.freeze(device, TODAY);
    assertEquals(2, after.streak());
    assertFalse(after.canFreeze());

    assertEquals(
        "cannot_freeze",
        assertThrows(CustomRuntimeException.class, () -> chains.freeze(device, TODAY)).code());
  }

  @Test
  @DisplayName("a day older than the queue could plausibly hold is refused")
  void refusesAnOldBackdate() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                chains.mark(
                    device, TODAY.minusDays(Chains.backdateDays + 1), TODAY));

    // Otherwise anyone could backfill a month-long streak.
    assertEquals("day_too_old", refused.code());
  }

  @Test
  @DisplayName("a day queued offline yesterday still counts")
  void acceptsARecentBackdate() {
    chains.start(device, TODAY);
    var state = chains.mark(device, TODAY.minusDays(1), TODAY);

    // The state that comes back is the state now, not the state on the day
    // the queue is replaying.
    assertEquals(2, state.streak());
  }

  @Test
  @DisplayName("a date the calendar does not have yet is refused")
  void refusesAnImpossibleDate() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () -> chains.mark(device, TODAY.plusDays(5), TODAY));

    assertEquals("impossible_date", refused.code());
  }

  @Test
  @DisplayName("a client one time zone ahead is not lying")
  void allowsClockSkew() {
    // Time zones span more than a day end to end.
    var state = chains.start(device, TODAY.plusDays(1));

    assertTrue(state.started());
  }

  @Test
  @DisplayName("deleting takes the chain and its days with it")
  void deletionRemovesEverything() {
    chains.start(device, TODAY);
    chains.deleteForDevice(device);

    assertFalse(chains.state(device, TODAY).started());
  }
}
