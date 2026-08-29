package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "mottos")
@IdClass(MottoRow.Key.class)
public class MottoRow {

  @Id
  private String id;

  @Id
  private String locale;

  @Column(name = "archetype_id", nullable = false)
  private String archetypeId;

  @Column(nullable = false)
  private String motto;

  @Column(nullable = false)
  private String detail;

  @Column(nullable = false)
  private String reminder;

  @Column(nullable = false)
  private int ordinal;

  protected MottoRow() {}

  public static MottoRow of(String id, String locale, String archetypeId, String motto, String detail, String reminder, int ordinal) {
    MottoRow row = new MottoRow();
    row.id = id;
    row.locale = locale;
    row.archetypeId = archetypeId;
    row.motto = motto;
    row.detail = detail;
    row.reminder = reminder;
    row.ordinal = ordinal;
    return row;
  }

  public String id() {
    return id;
  }

  public String locale() {
    return locale;
  }

  public String archetypeId() {
    return archetypeId;
  }

  public String motto() {
    return motto;
  }

  public String detail() {
    return detail;
  }

  public String reminder() {
    return reminder;
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
