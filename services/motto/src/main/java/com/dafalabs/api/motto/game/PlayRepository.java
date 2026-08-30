package com.dafalabs.api.motto.game;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.LocalDate;
import java.util.UUID;

@ApplicationScoped
public class PlayRepository implements PanacheRepository<Play> {

  public long countForDay(UUID deviceId, LocalDate day) {
    return count("deviceId = ?1 and day = ?2", deviceId, day);
  }
}
