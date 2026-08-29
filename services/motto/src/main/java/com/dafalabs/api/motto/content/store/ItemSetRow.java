package com.dafalabs.api.motto.content.store;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * A generation of the inventory.
 *
 * <p>A result is a profile measured with a particular set of questions.
 * Editing a question without saying so would quietly make old results
 * incomparable to new ones, so an edit is a new version and exactly one
 * version is active.
 */
@Entity
@Table(name = "item_sets")
public class ItemSetRow {

  @Id private int version;

  @Column(nullable = false)
  private boolean active;

  protected ItemSetRow() {}

  public int version() {
    return version;
  }

  public boolean active() {
    return active;
  }
}
