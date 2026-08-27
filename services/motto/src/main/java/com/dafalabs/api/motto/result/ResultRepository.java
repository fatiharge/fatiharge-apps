package com.dafalabs.api.motto.result;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class ResultRepository implements PanacheRepository<Result> {

  public List<Result> forDevice(UUID deviceId) {
    return list("deviceId", Sort.by("claimedAt", Sort.Direction.Descending), deviceId);
  }
}
