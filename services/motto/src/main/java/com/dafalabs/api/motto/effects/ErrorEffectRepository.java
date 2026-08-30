package com.dafalabs.api.motto.effects;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;

@ApplicationScoped
public class ErrorEffectRepository
    implements PanacheRepositoryBase<ErrorEffect, ErrorEffect.Key> {

  public List<ErrorEffect> forLocale(String locale) {
    return list("locale = ?1 order by code", locale);
  }
}
