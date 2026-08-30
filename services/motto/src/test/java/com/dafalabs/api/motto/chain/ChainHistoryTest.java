package com.dafalabs.api.motto.chain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import com.dafalabs.api.motto.chain.dto.ChainHistory;
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
class ChainHistoryTest {

  private static final LocalDate TODAY = LocalDate.of(2026, 3, 11);

  @Inject Chains chains;
  @InjectMock Clock clock;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    at(TODAY);
  }

  /// The chain reads the server's day through `withZone`, so a mock that only
  /// answers `instant` hands it a null and every date check dies on it.
  private void at(LocalDate day) {
    when(clock.instant()).thenReturn(day.atStartOfDay(ZoneOffset.UTC).toInstant());
    when(clock.getZone()).thenReturn(ZoneOffset.UTC);
    when(clock.withZone(ZoneOffset.UTC))
        .thenReturn(Clock.fixed(day.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC));
  }

  @Test
  @DisplayName("a device that has done nothing has no runs")
  void nothingYet() {
    assertTrue(chains.history(device).periods().isEmpty());
  }

  @Test
  @DisplayName("the days come back in order, which is what says which day they were")
  void daysAreOrdered() {
    chains.start(device, TODAY.minusDays(2));
    chains.mark(device, TODAY.minusDays(1), TODAY);
    chains.mark(device, TODAY.minusDays(2), TODAY);

    ChainHistory history = chains.history(device);

    assertEquals(1, history.periods().size());
    // The app reads the position as the day of the fourteen, so out of order
    // would hand somebody the wrong text for the day they are looking at.
    assertEquals(
        TODAY.minusDays(2), history.periods().getFirst().days().getFirst().day());
    assertEquals(2, history.periods().getFirst().days().size());
    assertTrue(history.periods().getFirst().current());
  }

  @Test
  @DisplayName("a finished run keeps its days under its own number")
  void finishedRunsStay() {
    // Walked day by day rather than backfilled: a mark older than a week is
    // refused, which is the rule that stops anybody inventing a streak.
    LocalDate start = TODAY.minusDays(14);
    at(start);
    chains.start(device, start);
    for (int i = 0; i < 14; i++) {
      LocalDate day = start.plusDays(i);
      at(day);
      chains.mark(device, day, day);
    }

    at(TODAY);
    chains.nextPeriod(device, null, TODAY);
    chains.mark(device, TODAY, TODAY);

    ChainHistory history = chains.history(device);

    assertEquals(2, history.periods().size());
    assertEquals(14, history.periods().getFirst().days().size());
    assertFalse(history.periods().getFirst().current());
    assertTrue(history.periods().getLast().current());
  }
}
