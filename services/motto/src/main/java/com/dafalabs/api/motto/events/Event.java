package com.dafalabs.api.motto.events;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** One thing that happened on one phone. */
@Entity
@Table(name = "events")
public class Event {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "device_id", nullable = false, updatable = false)
  private UUID deviceId;

  @Column(nullable = false, updatable = false)
  private String name;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(nullable = false, updatable = false)
  private String properties;

  @Column(name = "occurred_at", nullable = false, updatable = false)
  private Instant occurredAt;

  /// Generated on the phone, so a retry that actually landed the first time is
  /// rejected by the unique constraint rather than counted twice.
  @Column(name = "client_id", nullable = false, updatable = false)
  private UUID clientId;

  protected Event() {
    // for Hibernate
  }

  static Event of(UUID deviceId, String name, String properties, Instant occurredAt, UUID clientId) {
    Event event = new Event();
    event.deviceId = deviceId;
    event.name = name;
    event.properties = properties;
    event.occurredAt = occurredAt;
    event.clientId = clientId;
    return event;
  }
}
