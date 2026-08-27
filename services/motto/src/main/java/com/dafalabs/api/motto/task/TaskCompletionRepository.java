package com.dafalabs.api.motto.task;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class TaskCompletionRepository
    implements PanacheRepositoryBase<TaskCompletion, TaskCompletion.Key> {

  public List<TaskCompletion> forDevice(UUID deviceId) {
    return list("deviceId", deviceId);
  }
}
