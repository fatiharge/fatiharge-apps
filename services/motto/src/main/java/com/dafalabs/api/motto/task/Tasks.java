package com.dafalabs.api.motto.task;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.chain.dto.ChainState;
import com.dafalabs.api.motto.game.CreditReason;
import com.dafalabs.api.motto.game.Plays;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.task.dto.DailyTask;
import com.dafalabs.api.motto.task.dto.DailyTasks;
import com.dafalabs.api.motto.task.dto.PeriodReport;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/** The three things a day asks for, and what was done about them. */
@ApplicationScoped
public class Tasks {

  /// The fourteen days a motto lasts. The day index wraps rather than running
  /// out: a chain that outlives the content repeats, which beats stopping.
  public static final int periodDays = 14;

  static final int perDay = 3;

  private final TaskRepository tasks;
  private final TaskCompletionRepository completions;
  private final Results results;
  private final Plays plays;

  Tasks(
      TaskRepository tasks,
      TaskCompletionRepository completions,
      Results results,
      Plays plays) {
    this.tasks = tasks;
    this.completions = completions;
    this.results = results;
    this.plays = plays;
  }

  /**
   * Which of the fourteen days a chain of {@code marked} length is on.
   *
   * <p>Counted from days marked rather than from the current streak: losing
   * your place in the content because you missed two days punishes the person
   * who came back.
   */
  public static int dayIndex(int marked) {
    int position = marked < 1 ? 0 : marked - 1;
    return position % periodDays + 1;
  }

  @Transactional
  public DailyTasks forToday(UUID deviceId, ChainState chain) {
    int day = dayIndex(chain.markedDays().size());

    String archetype = archetypeOf(deviceId);
    if (archetype == null) {
      // Nothing is asked of someone the app knows nothing about.
      return new DailyTasks(day, List.of());
    }

    Set<Long> done = doneIds(deviceId);
    return new DailyTasks(
        day,
        tasks.forDay(day, archetype).stream()
            .map(
                task ->
                    new DailyTask(
                        task.id(),
                        task.ordinal(),
                        task.title(),
                        task.detail(),
                        done.contains(task.id())))
            .toList());
  }

  @Transactional
  public void complete(UUID deviceId, long taskId, LocalDate day) {
    Task task = tasks.findById(taskId);
    if (task == null) {
      throw new CustomRuntimeException(404, "no_such_task", "That task does not exist.");
    }

    // Ticking the same task twice is ticking it once, and the app will send it
    // twice the moment somebody double taps.
    if (completions.findById(new TaskCompletion.Key(deviceId, taskId)) == null) {
      completions.persist(TaskCompletion.of(deviceId, taskId, day));
    }

    // Counted rather than assumed from this call: the tick that finishes the
    // day is not always the third one to arrive, and a double tap must not
    // pay twice. `grant` is idempotent for the same reason.
    if (completions.countForDay(deviceId, day) >= perDay) {
      plays.grant(deviceId, day, CreditReason.TASKS_DONE);
    }
  }

  @Transactional
  public PeriodReport report(UUID deviceId, ChainState chain) {
    int marked = chain.markedDays().size();
    int madeUp = (int) chain.markedDays().stream().filter(day -> day.madeUp()).count();
    int day = dayIndex(marked);

    String archetype = archetypeOf(deviceId);
    int offered = archetype == null ? 0 : Math.min(marked, periodDays) * perDay;

    return new PeriodReport(
        day,
        Math.min(marked, periodDays),
        madeUp,
        doneIds(deviceId).size(),
        offered,
        marked >= periodDays);
  }

  @Transactional
  public void deleteForDevice(UUID deviceId) {
    completions.delete("deviceId", deviceId);
  }

  private Set<Long> doneIds(UUID deviceId) {
    return completions.forDevice(deviceId).stream()
        .map(TaskCompletion::taskId)
        .collect(Collectors.toSet());
  }

  private String archetypeOf(UUID deviceId) {
    return results.forDevice(deviceId).stream()
        .findFirst()
        .map(result -> result.archetypeId())
        .orElse(null);
  }
}
