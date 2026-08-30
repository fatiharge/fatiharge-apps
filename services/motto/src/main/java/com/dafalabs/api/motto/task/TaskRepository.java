package com.dafalabs.api.motto.task;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.Optional;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {

  /**
   * The three things, in the reader's language.
   *
   * <p>Empty rather than falling back to Turkish: three sentences half in one
   * language is worse than a day the app can say nothing about, and the caller
   * is the one that knows what to do about it.
   */
  public List<Task> forDay(String locale, int day, String archetypeId) {
    return list(
        "locale = ?1 and day = ?2 and archetypeId = ?3 and active",
        Sort.by("ordinal"),
        locale,
        day,
        archetypeId);
  }

  /** The slot a pushed task addresses. */
  public Optional<Task> inSlot(String locale, int day, String archetypeId, int ordinal) {
    return find(
            "locale = ?1 and day = ?2 and archetypeId = ?3 and ordinal = ?4",
            locale,
            day,
            archetypeId,
            ordinal)
        .firstResultOptional();
  }

  public long unwritten(String locale) {
    return count("locale = ?1 and placeholder", locale);
  }

  public List<Task> forArchetype(String locale, String archetypeId) {
    return list(
        "locale = ?1 and archetypeId = ?2 and active",
        Sort.by("day", "ordinal"),
        locale,
        archetypeId);
  }

  /** Every language a task has been written in, for the admin's report. */
  public List<Task> listAll(String locale) {
    return list("locale = ?1", locale);
  }
}
