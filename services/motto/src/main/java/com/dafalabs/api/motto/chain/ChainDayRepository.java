package com.dafalabs.api.motto.chain;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class ChainDayRepository implements PanacheRepositoryBase<ChainDay, ChainDay.Key> {

  public List<ChainDay> forDevice(UUID deviceId) {
    return list("deviceId", deviceId);
  }

  /// This run's days. The finished ones stay in the table under their own
  /// period so their report keeps working.
  public List<ChainDay> forPeriod(UUID deviceId, short period) {
    return list("deviceId = ?1 and period = ?2", deviceId, period);
  }

  public boolean exists(UUID deviceId, LocalDate day) {
    return count("deviceId = ?1 and day = ?2", deviceId, day) > 0;
  }
}
