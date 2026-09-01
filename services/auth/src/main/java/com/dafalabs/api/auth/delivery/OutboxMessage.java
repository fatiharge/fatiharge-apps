package com.dafalabs.api.auth.delivery;

import com.dafalabs.api.auth.identity.IdentityType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/** One message waiting for a channel that does not exist yet. */
@Entity
@Table(name = "message_outbox")
public class OutboxMessage {

  @Id private UUID id;

  @Column(name = "tenant_id", nullable = false, updatable = false)
  private UUID tenantId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  private IdentityType channel;

  @Column(nullable = false, updatable = false)
  private String recipient;

  @Column(nullable = false, updatable = false)
  private String template;

  @Column(nullable = false, updatable = false)
  private String variables;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private DeliveryStatus status;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @Column(name = "sent_at")
  private Instant sentAt;

  protected OutboxMessage() {
    // for Hibernate
  }

  static OutboxMessage pending(
      UUID tenantId,
      IdentityType channel,
      String recipient,
      String template,
      String variables,
      Instant now) {
    OutboxMessage message = new OutboxMessage();
    message.id = UUID.randomUUID();
    message.tenantId = tenantId;
    message.channel = channel;
    message.recipient = recipient;
    message.template = template;
    message.variables = variables;
    message.status = DeliveryStatus.PENDING;
    message.createdAt = now;
    return message;
  }

  public void markSent(Instant now) {
    status = DeliveryStatus.SENT;
    sentAt = now;
  }

  public UUID id() {
    return id;
  }

  public UUID tenantId() {
    return tenantId;
  }

  public IdentityType channel() {
    return channel;
  }

  public String recipient() {
    return recipient;
  }

  public String template() {
    return template;
  }

  public String variables() {
    return variables;
  }

  public DeliveryStatus status() {
    return status;
  }
}
