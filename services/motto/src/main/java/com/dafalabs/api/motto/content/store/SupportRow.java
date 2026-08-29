package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "support_texts")
@IdClass(SupportRow.Key.class)
public class SupportRow {

  @Id
  private String kind;

  @Id
  private String key;

  @Id
  private String locale;

  @Column(nullable = true)
  private String heading;

  @Column(nullable = false)
  private String body;

  @Column(nullable = false)
  private int ordinal;

  protected SupportRow() {}

  public static SupportRow of(String kind, String key, String locale, String heading, String body, int ordinal) {
    SupportRow row = new SupportRow();
    row.kind = kind;
    row.key = key;
    row.locale = locale;
    row.heading = heading;
    row.body = body;
    row.ordinal = ordinal;
    return row;
  }

  public String kind() {
    return kind;
  }

  public String key() {
    return key;
  }

  public String locale() {
    return locale;
  }

  public String heading() {
    return heading;
  }

  public String body() {
    return body;
  }

  public int ordinal() {
    return ordinal;
  }

  public static class Key implements Serializable {
    private String kind;
    private String key;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(kind, that.kind)
          && java.util.Objects.equals(key, that.key)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(kind, key, locale);
    }
  }
}
