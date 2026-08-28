package com.dafalabs.api.motto.task;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.Optional;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {

  public List<Task> forDay(int day, String archetypeId) {
    return list(
        "day = ?1 and archetypeId = ?2 and active",
        Sort.by("ordinal"),
        day,
        archetypeId);
  }

  /** The slot a pushed task addresses. */
  public Optional<Task> inSlot(int day, String archetypeId, int ordinal) {
    return find("day = ?1 and archetypeId = ?2 and ordinal = ?3", day, archetypeId, ordinal)
        .firstResultOptional();
  }

  public long unwritten() {
    return count("placeholder");
  }

  public List<Task> forArchetype(String archetypeId) {
    return list("archetypeId = ?1 and active", Sort.by("day", "ordinal"), archetypeId);
  }
}
