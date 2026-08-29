package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "items")
@IdClass(ItemRow.Key.class)
public class ItemRow {

  @Id
  private String id;

  @Id
  private int version;

  @Id
  private String locale;

  @Column(nullable = false)
  private String dimension;

  @Column(nullable = false)
  private boolean reverse;

  @Column(nullable = false)
  private String text;

  @Column(nullable = false)
  private int ordinal;

  protected ItemRow() {}

  public static ItemRow of(String id, int version, String locale, String dimension, boolean reverse, String text, int ordinal) {
    ItemRow row = new ItemRow();
    row.id = id;
    row.version = version;
    row.locale = locale;
    row.dimension = dimension;
    row.reverse = reverse;
    row.text = text;
    row.ordinal = ordinal;
    return row;
  }

  public String id() {
    return id;
  }

  public int version() {
    return version;
  }

  public String locale() {
    return locale;
  }

  public String dimension() {
    return dimension;
  }

  public boolean reverse() {
    return reverse;
  }

  public String text() {
    return text;
  }

  public int ordinal() {
    return ordinal;
  }

  public static class Key implements Serializable {
    private String id;
    private int version;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(id, that.id)
          && java.util.Objects.equals(version, that.version)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(id, version, locale);
    }
  }
}
