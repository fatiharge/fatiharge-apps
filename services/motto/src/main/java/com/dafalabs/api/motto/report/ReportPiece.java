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

  protected ReportPiece() {}

  public Integer section() {
    return section;
  }

  public String text() {
    return text;
  }
}
