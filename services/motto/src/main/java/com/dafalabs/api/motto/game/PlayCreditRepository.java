package com.dafalabs.api.motto.game;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class PlayCreditRepository implements PanacheRepositoryBase<PlayCredit, PlayCredit.Key> {

  public List<PlayCredit> forDay(UUID deviceId, LocalDate day) {
    return list("deviceId = ?1 and day = ?2", deviceId, day);
  }
}
