package com.dafalabs.api.motto.report;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "report_pieces")
public class ReportPiece {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String kind;

  @Column(name = "archetype_id")
  private String archetypeId;

  private String dimension;

  private String band;

  /// The second axis a section reads, and where this reader lands on it. Null
  /// on every piece that is not a paired reading.
  @Column(name = "dimension_2")
  private String dimension2;

  @Column(name = "band_2")
  private String band2;

  private Integer section;

  @Column(nullable = false)
  private String text;

  /// True while the text is a stand-in rather than something somebody wrote.
  @Column(nullable = false)
  private boolean placeholder;

  protected ReportPiece() {}

  /** Written by the content push, and by nothing else. */
  public static ReportPiece of(
      String kind,
      String archetypeId,
      String dimension,
      String band,
      Integer section,
      String text,
      boolean placeholder) {
    return of(kind, archetypeId, dimension, band, null, null, section, text, placeholder);
  }

  /** Written by the content push, and by nothing else. */
  public static ReportPiece of(
      String kind,
      String archetypeId,
      String dimension,
      String band,
      String dimension2,
      String band2,
      Integer section,
      String text,
      boolean placeholder) {
    ReportPiece piece = new ReportPiece();
    piece.kind = kind;
    piece.archetypeId = archetypeId;
    piece.dimension = dimension;
    piece.band = band;
    piece.dimension2 = dimension2;
    piece.band2 = band2;
    piece.section = section;
    piece.rewrite(text, placeholder);
    return piece;
  }

  public void rewrite(String text, boolean placeholder) {
    this.text = text;
    this.placeholder = placeholder;
  }

  public String kind() {
    return kind;
  }

  public String archetypeId() {
    return archetypeId;
  }

  public String dimension2() {
    return dimension2;
  }

  public String band2() {
    return band2;
  }

  public String dimension() {
    return dimension;
  }

  public String band() {
    return band;
  }

  public Integer section() {
    return section;
  }

  public String text() {
    return text;
  }
}
