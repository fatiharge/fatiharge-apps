package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

/** An archetype's words. The point it sits on is {@link RuleRow}. */
@Entity
@Table(name = "archetypes")
@IdClass(ArchetypeRow.Key.class)
public class ArchetypeRow {

  @Id private String id;

  @Id private String locale;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false)
  private String summary;

  @Column(nullable = false)
  private String motto;

  @Column(nullable = false)
  private int ordinal;

  protected ArchetypeRow() {}

  public static ArchetypeRow of(
      String id, String locale, String name, String summary, String motto, int ordinal) {
    ArchetypeRow row = new ArchetypeRow();
    row.id = id;
    row.locale = locale;
    row.ordinal = ordinal;
    row.rewrite(name, summary, motto);
    return row;
  }

  public void rewrite(String name, String summary, String motto) {
    this.name = name;
    this.summary = summary;
    this.motto = motto;
  }

  public String id() {
    return id;
  }

  public String locale() {
    return locale;
  }

  public String name() {
    return name;
  }

  public String summary() {
    return summary;
  }

  public String motto() {
    return motto;
  }

  public int ordinal() {
    return ordinal;
  }

  public static class Key implements Serializable {
    private String id;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(id, that.id)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(id, locale);
    }
  }
}
