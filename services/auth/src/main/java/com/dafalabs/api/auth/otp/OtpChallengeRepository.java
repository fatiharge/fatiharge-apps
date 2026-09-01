package com.dafalabs.api.auth.otp;

import com.dafalabs.api.auth.identity.IdentityType;
import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.Instant;
import java.util.UUID;

@ApplicationScoped
public class OtpChallengeRepository implements PanacheRepositoryBase<OtpChallenge, UUID> {

  /**
   * How many codes this identity has been sent since a moment.
   *
   * <p>Counted rather than kept in a counter column so the window can move: a
   * stored count would have to be reset by something, and whatever reset it
   * would be the thing that broke.
   */
  public long issuedSince(UUID tenantId, IdentityType type, String value, Instant since) {
    return count(
        "tenantId = ?1 and identityType = ?2 and identityValue = ?3 and createdAt >= ?4",
        tenantId,
        type,
        value,
        since);
  }
}
