package com.dafalabs.api.auth.delivery;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class OutboxRepository implements PanacheRepositoryBase<OutboxMessage, UUID> {

  /** What a sender would take, once there is one. Oldest first. */
  public List<OutboxMessage> pending(int limit) {
    return find("status", DeliveryStatus.PENDING).page(0, limit).list();
  }

  public List<OutboxMessage> to(UUID tenantId, String recipient) {
    return find("tenantId = ?1 and recipient = ?2 order by createdAt desc", tenantId, recipient)
        .list();
  }
}
