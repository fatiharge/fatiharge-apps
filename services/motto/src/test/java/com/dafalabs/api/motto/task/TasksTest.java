package com.dafalabs.api.motto.task;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.chain.Chains;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class TasksTest {

  private static final LocalDate TODAY = LocalDate.of(2026, 3, 10);

  @Inject Tasks tasks;
  @Inject Chains chains;
  @Inject Results results;
  @InjectMock Clock clock;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    when(clock.instant()).thenReturn(TODAY.atStartOfDay(ZoneOffset.UTC).toInstant());
    when(clock.getZone()).thenReturn(ZoneOffset.UTC);
    when(clock.withZone(ZoneOffset.UTC))
        .thenReturn(Clock.fixed(TODAY.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC));
  }

  @Transactional
  void givenAResult() {
    Map<Dimension, Double> scores = new EnumMap<>(Dimension.class);
    for (Dimension dimension : Dimension.values()) {
      scores.put(dimension, 0.5);
    }
    results.record(device, "quiet_builder", new ProfileVector(scores));
  }

  @Test
  @DisplayName("the day index follows how many days were marked, and wraps")
  void theDayIndexWraps() {
    // Losing your place because you missed two days punishes the person who
    // came back, so it counts marked days rather than the current streak.
    assertEquals(1, Tasks.dayIndex(0));
    assertEquals(1, Tasks.dayIndex(1));
    assertEquals(14, Tasks.dayIndex(14));
    assertEquals(1, Tasks.dayIndex(15));
  }

  @Test
  @DisplayName("nothing is asked of someone with no result")
  void noResultMeansNoTasks() {
    chains.start(device, TODAY);

    assertTrue(tasks.forToday(device, chains.state(device, TODAY)).tasks().isEmpty());
  }

  @Test
  @DisplayName("a day asks for three things")
  void aDayHasThreeTasks() {
    givenAResult();
    chains.start(device, TODAY);

    var today = tasks.forToday(device, chains.state(device, TODAY));

    assertEquals(1, today.day());
    assertEquals(3, today.tasks().size());
    assertEquals(1, today.tasks().get(0).ordinal());
  }

  @Test
  @DisplayName("ticking one off sticks, and ticking it twice is ticking it once")
  void tickingIsIdempotent() {
    givenAResult();
    chains.start(device, TODAY);
    var first = tasks.forToday(device, chains.state(device, TODAY)).tasks().get(0);
    assertFalse(first.done());

    tasks.complete(device, first.id(), TODAY);
    tasks.complete(device, first.id(), TODAY);

    var after = tasks.forToday(device, chains.state(device, TODAY));
    assertTrue(after.tasks().get(0).done());
    assertEquals(1, tasks.report(device, chains.state(device, TODAY)).tasksDone());
  }

  @Test
  @DisplayName("a task that does not exist is refused by its own code")
  void refusesAnUnknownTask() {
    var refused =
        assertThrows(
            CustomRuntimeException.class, () -> tasks.complete(device, 999999, TODAY));

    assertEquals("no_such_task", refused.code());
  }

  @Test
  @DisplayName("the report counts made-up days apart from marked ones")
  void theReportSeparatesMadeUpDays() {
    givenAResult();
    chains.start(device, TODAY.minusDays(2));
    chains.freeze(device, TODAY);

    var report = tasks.report(device, chains.state(device, TODAY));

    // A report that counts them as the same thing is flattering rather than
    // useful.
    assertEquals(2, report.daysMarked());
    assertEquals(1, report.daysMadeUp());
    assertFalse(report.complete());
  }

  @Test
  @DisplayName("the period is complete only after fourteen days")
  void thePeriodCompletes() {
    givenAResult();
    chains.start(device, TODAY.minusDays(6));
    for (int back = 5; back >= 0; back--) {
      chains.mark(device, TODAY.minusDays(back), TODAY);
    }

    assertFalse(tasks.report(device, chains.state(device, TODAY)).complete());
  }
}
