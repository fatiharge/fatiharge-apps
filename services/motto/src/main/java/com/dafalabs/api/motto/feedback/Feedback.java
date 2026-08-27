package com.dafalabs.api.motto.feedback;

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

/** One thing someone told us. */
@Entity
@Table(name = "feedback")
public class Feedback {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "device_id", nullable = false, updatable = false)
  private UUID deviceId;

  @Column(nullable = false, updatable = false)
  private String kind;

  @Column(nullable = false, updatable = false)
  private String message;

  @Column(updatable = false)
  private String email;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(nullable = false, updatable = false)
  private String context;

  @Column(name = "created_at", nullable = false, insertable = false, updatable = false)
  private Instant createdAt;

  protected Feedback() {}

  static Feedback of(UUID deviceId, String kind, String message, String email, String context) {
    Feedback feedback = new Feedback();
    feedback.deviceId = deviceId;
    feedback.kind = kind;
    feedback.message = message;
    feedback.email = email;
    feedback.context = context;
    return feedback;
  }

  public Long id() {
    return id;
  }

  public UUID deviceId() {
    return deviceId;
  }

  public String kind() {
    return kind;
  }

  public String message() {
    return message;
  }

  public String email() {
    return email;
  }
}
