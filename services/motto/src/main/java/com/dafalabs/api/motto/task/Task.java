package com.dafalabs.api.motto.task;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tasks")
public class Task {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private int day;

  @Column(name = "archetype_id", nullable = false)
  private String archetypeId;

  @Column(nullable = false)
  private int ordinal;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false)
  private String detail;

  @Column(nullable = false)
  private boolean active;

  protected Task() {}

  public Long id() {
    return id;
  }

  public int day() {
    return day;
  }

  public int ordinal() {
    return ordinal;
  }

  public String title() {
    return title;
  }

  public String detail() {
    return detail;
  }
}
