package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "connectors")
@IdClass(ConnectorRow.Key.class)
public class ConnectorRow {

  @Id
  private String id;

  @Id
  private String locale;

  @Column(nullable = false)
  private String text;

  protected ConnectorRow() {}

  public static ConnectorRow of(String id, String locale, String text) {
    ConnectorRow row = new ConnectorRow();
    row.id = id;
    row.locale = locale;
    row.text = text;
    return row;
  }

  public String id() {
    return id;
  }

  public String locale() {
    return locale;
  }

  public String text() {
    return text;
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
