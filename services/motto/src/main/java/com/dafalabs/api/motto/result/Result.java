package com.dafalabs.api.motto.result;

import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;

/** One motto that was claimed, and the profile that produced it. */
@Entity
@Table(name = "results")
public class Result {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "device_id", nullable = false, updatable = false)
  private UUID deviceId;

  @Column(name = "archetype_id", nullable = false, updatable = false)
  private String archetypeId;

  @Column(nullable = false, updatable = false)
  private float openness;

  @Column(nullable = false, updatable = false)
  private float conscientiousness;

  @Column(nullable = false, updatable = false)
  private float extraversion;

  @Column(nullable = false, updatable = false)
  private float agreeableness;

  @Column(nullable = false, updatable = false)
  private float neuroticism;

  @Column(name = "claimed_at", nullable = false, insertable = false, updatable = false)
  private Instant claimedAt;

  protected Result() {}

  static Result of(UUID deviceId, String archetypeId, ProfileVector profile) {
    Result result = new Result();
    result.deviceId = deviceId;
    result.archetypeId = archetypeId;
    result.openness = (float) profile.at(Dimension.OPENNESS);
    result.conscientiousness = (float) profile.at(Dimension.CONSCIENTIOUSNESS);
    result.extraversion = (float) profile.at(Dimension.EXTRAVERSION);
    result.agreeableness = (float) profile.at(Dimension.AGREEABLENESS);
    result.neuroticism = (float) profile.at(Dimension.NEUROTICISM);
    return result;
  }

  public Long id() {
    return id;
  }

  public String archetypeId() {
    return archetypeId;
  }

  public Instant claimedAt() {
    return claimedAt;
  }

  public Map<Dimension, Double> profile() {
    Map<Dimension, Double> scores = new EnumMap<>(Dimension.class);
    scores.put(Dimension.OPENNESS, (double) openness);
    scores.put(Dimension.CONSCIENTIOUSNESS, (double) conscientiousness);
    scores.put(Dimension.EXTRAVERSION, (double) extraversion);
    scores.put(Dimension.AGREEABLENESS, (double) agreeableness);
    scores.put(Dimension.NEUROTICISM, (double) neuroticism);
    return scores;
  }
}
