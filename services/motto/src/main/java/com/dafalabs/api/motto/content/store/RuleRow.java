package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.List;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * Where an archetype sits in the five-dimensional space.
 *
 * <p>A row rather than a line in a file, so the nineteenth archetype is a
 * write. What that costs is a gate on the way in: nothing reaches this table
 * unless every archetype still wins on its own point.
 */
@Entity
@Table(name = "archetype_rules")
public class RuleRow {

  @Id
  @Column(name = "archetype_id")
  private String archetypeId;

  @JdbcTypeCode(SqlTypes.ARRAY)
  @Column(nullable = false)
  private List<String> defining;

  @Column(nullable = false)
  private float openness;

  @Column(nullable = false)
  private float conscientiousness;

  @Column(nullable = false)
  private float extraversion;

  @Column(nullable = false)
  private float agreeableness;

  @Column(nullable = false)
  private float neuroticism;

  protected RuleRow() {}

  public static RuleRow of(String archetypeId, List<String> defining, java.util.Map<String, Double> target) {
    RuleRow row = new RuleRow();
    row.archetypeId = archetypeId;
    row.rewrite(defining, target);
    return row;
  }

  public void rewrite(List<String> defining, java.util.Map<String, Double> target) {
    this.defining = List.copyOf(defining);
    openness = target.get("openness").floatValue();
    conscientiousness = target.get("conscientiousness").floatValue();
    extraversion = target.get("extraversion").floatValue();
    agreeableness = target.get("agreeableness").floatValue();
    neuroticism = target.get("neuroticism").floatValue();
  }

  public String archetypeId() {
    return archetypeId;
  }

  public List<String> defining() {
    return defining;
  }

  public java.util.Map<String, Double> target() {
    return java.util.Map.of(
        "openness", (double) openness,
        "conscientiousness", (double) conscientiousness,
        "extraversion", (double) extraversion,
        "agreeableness", (double) agreeableness,
        "neuroticism", (double) neuroticism);
  }
}
