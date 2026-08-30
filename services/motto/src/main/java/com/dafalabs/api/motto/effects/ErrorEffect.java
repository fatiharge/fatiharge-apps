package com.dafalabs.api.motto.effects;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

/** What one refusal leads to, in one language. */
@Entity
@Table(name = "error_effects")
@IdClass(ErrorEffect.Key.class)
public class ErrorEffect {

  @Id
  @Column(updatable = false)
  private String code;

  @Id
  @Column(updatable = false)
  private String locale;

  @Column(nullable = false)
  private String definition;

  protected ErrorEffect() {}

  static ErrorEffect of(String code, String locale, String definition) {
    ErrorEffect effect = new ErrorEffect();
    effect.code = code;
    effect.locale = locale;
    effect.definition = definition;
    return effect;
  }

  public String code() {
    return code;
  }

  public String definition() {
    return definition;
  }

  void rewrite(String definition) {
    this.definition = definition;
  }

  public record Key(String code, String locale) implements Serializable {
    public Key() {
      this(null, null);
    }
  }
}
