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
    ReportPiece piece = new ReportPiece();
    piece.kind = kind;
    piece.archetypeId = archetypeId;
    piece.dimension = dimension;
    piece.band = band;
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
