package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "report_sections")
@IdClass(ReportSectionRow.Key.class)
public class ReportSectionRow {

  @Id
  private int section;

  @Id
  private String locale;

  @Column(nullable = false)
  private String dimension;

  /// The second axis this section reads. Null while it reads only one, which
  /// is what every section did before the report learned to cross them.
  @Column(name = "dimension_2")
  private String dimension2;

  protected ReportSectionRow() {}

  public static ReportSectionRow of(int section, String locale, String dimension) {
    ReportSectionRow row = new ReportSectionRow();
    row.section = section;
    row.locale = locale;
    row.dimension = dimension;
    return row;
  }

  public int section() {
    return section;
  }

  public String locale() {
    return locale;
  }

  public String dimension() {
    return dimension;
  }

  public String dimension2() {
    return dimension2;
  }

  public static class Key implements Serializable {
    private int section;
    private String locale;

    @Override
    public boolean equals(Object other) {
      return other instanceof Key that
          && java.util.Objects.equals(section, that.section)
          && java.util.Objects.equals(locale, that.locale);
    }

    @Override
    public int hashCode() {
      return java.util.Objects.hash(section, locale);
    }
  }
}
