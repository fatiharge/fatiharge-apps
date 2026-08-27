package com.dafalabs.api.motto.task;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "task_completions")
@IdClass(TaskCompletion.Key.class)
public class TaskCompletion {

  @Id
  @Column(name = "device_id", updatable = false)
  private UUID deviceId;

  @Id
  @Column(name = "task_id", updatable = false)
  private Long taskId;

  @Column(nullable = false, updatable = false)
  private LocalDate day;

  protected TaskCompletion() {}

  static TaskCompletion of(UUID deviceId, Long taskId, LocalDate day) {
    TaskCompletion done = new TaskCompletion();
    done.deviceId = deviceId;
    done.taskId = taskId;
    done.day = day;
    return done;
  }

  public Long taskId() {
    return taskId;
  }

  public LocalDate day() {
    return day;
  }

  public record Key(UUID deviceId, Long taskId) implements Serializable {
    public Key() {
      this(null, null);
    }
  }
}
