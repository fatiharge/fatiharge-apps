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

  /// True while the text is a stand-in rather than something somebody wrote,
  /// so what is left to write is a query.
  @Column(nullable = false)
  private boolean placeholder;

  protected Task() {}

  /** Written by the content push, and by nothing else. */
  public static Task of(
      int day, String archetypeId, int ordinal, String title, String detail, boolean placeholder) {
    Task task = new Task();
    task.day = day;
    task.archetypeId = archetypeId;
    task.ordinal = ordinal;
    task.active = true;
    task.rewrite(title, detail, placeholder);
    return task;
  }

  public void rewrite(String title, String detail, boolean placeholder) {
    this.title = title;
    this.detail = detail;
    this.placeholder = placeholder;
  }

  public Long id() {
    return id;
  }

  public int day() {
    return day;
  }

  public String archetypeId() {
    return archetypeId;
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
