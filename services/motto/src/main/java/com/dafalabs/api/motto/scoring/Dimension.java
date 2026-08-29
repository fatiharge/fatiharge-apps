package com.dafalabs.api.motto.scoring;

/** The five the item pool measures. */
public enum Dimension {
  OPENNESS,
  CONSCIENTIOUSNESS,
  EXTRAVERSION,
  AGREEABLENESS,
  NEUROTICISM;

  public static Dimension of(String name) {
    return valueOf(name.toUpperCase(java.util.Locale.ROOT));
  }
}
