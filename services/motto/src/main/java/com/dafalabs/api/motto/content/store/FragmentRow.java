package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "fragments")
@IdClass(FragmentRow.Key.class)
public class FragmentRow {

  @Id
  @Column(name = "archetype_id")
  private String archetypeId;

  @Id
  private int ordinal;

  @Id
  private String locale;

  @Column(nullable = false)
  private String text;

  protected FragmentRow() {}

  public static FragmentRow of(String archetypeId, int ordinal, String locale, String text) {
    FragmentRow row = new FragmentRow();
    row.archetypeId = archetypeId;
    row.ordinal = ordinal;
    row.locale = locale;
    row.text = text;
    return row;
  }

  public String archetypeId() {
    return archetypeId;
  }

  public int ordinal() {
    return ordinal;
  }

  public String locale() {
    return locale;
  }

  public String text() {
    return text;
  }

  public static class Key implements Serializable {
    private String archetypeId;
    private int ordinal;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(archetypeId, that.archetypeId)
          && java.util.Objects.equals(ordinal, that.ordinal)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(archetypeId, ordinal, locale);
    }
  }
}
