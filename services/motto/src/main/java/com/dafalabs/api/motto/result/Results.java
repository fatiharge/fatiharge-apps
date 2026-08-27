package com.dafalabs.api.motto.result;

import com.dafalabs.api.motto.scoring.ProfileVector;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class Results {

  private final ResultRepository repository;

  Results(ResultRepository repository) {
    this.repository = repository;
  }

  /// In the caller's transaction: a result that was returned but not recorded
  /// is a use that was spent and cannot be shown again.
  public Result record(UUID deviceId, String archetypeId, ProfileVector profile) {
    Result result = Result.of(deviceId, archetypeId, profile);
    repository.persist(result);
    return result;
  }

  @Transactional
  public List<Result> forDevice(UUID deviceId) {
    return repository.forDevice(deviceId);
  }

  @Transactional
  public long deleteForDevice(UUID deviceId) {
    return repository.delete("deviceId", deviceId);
  }
}
