package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "day_skeletons")
@IdClass(SkeletonRow.Key.class)
public class SkeletonRow {

  @Id
  private int day;

  @Id
  private String locale;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false)
  private String body;

  @Column(nullable = false)
  private String action;

  protected SkeletonRow() {}

  public static SkeletonRow of(int day, String locale, String title, String body, String action) {
    SkeletonRow row = new SkeletonRow();
    row.day = day;
    row.locale = locale;
    row.title = title;
    row.body = body;
    row.action = action;
    return row;
  }

  public int day() {
    return day;
  }

  public String locale() {
    return locale;
  }

  public String title() {
    return title;
  }

  public String body() {
    return body;
  }

  public String action() {
    return action;
  }

  public static class Key implements Serializable {
    private int day;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(day, that.day)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(day, locale);
    }
  }
}
