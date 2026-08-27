package com.dafalabs.api.motto.entitlement;

import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import org.eclipse.microprofile.config.inject.ConfigProperty;

/**
 * The rules about how often a device may take a motto.
 *
 * <p>All of it is decided here, against the server's clock, because the client's
 * clock is a setting. A counter the user can move is not a counter.
 *
 * <p>The endpoint that spends a use arrives with scoring: what a device gets
 * back and what it pays for it are one transaction, so that a result cannot be
 * produced without the use being spent.
 */
@ApplicationScoped
public class Entitlements {

  private final EntitlementRepository repository;
  private final Clock clock;
  private final int freeUses;
  private final Duration cooldown;
  private final int skipsAtStart;

  Entitlements(
      EntitlementRepository repository,
      Clock clock,
      @ConfigProperty(name = "motto.entitlement.free-uses") int freeUses,
      @ConfigProperty(name = "motto.entitlement.cooldown") Duration cooldown,
      @ConfigProperty(name = "motto.entitlement.skips-at-start") int skipsAtStart) {
    this.repository = repository;
    this.clock = clock;
    this.freeUses = freeUses;
    this.cooldown = cooldown;
    this.skipsAtStart = skipsAtStart;
  }

  /**
   * The state of a device, creating its row the first time it is asked about.
   *
   * <p>Created on read rather than on registration: a device that never opens
   * this app should not have a row here, and the app that does open it should
   * not need a separate call before it can ask anything.
   */
  @Transactional
  public EntitlementState stateOf(UUID deviceId) {
    return describe(rowFor(deviceId));
  }

  /**
   * Turns a device premium.
   *
   * <p>The one place it happens, so receipt verification has somewhere to call
   * and nothing else has to know how premium is stored. Idempotent: a store
   * that delivers the same purchase twice is a store, not a bug.
   */
  @Transactional
  public EntitlementState grantPremium(UUID deviceId) {
    Entitlement entitlement = rowFor(deviceId);
    entitlement.markPurchased(clock.instant());
    return describe(entitlement);
  }

  /**
   * Spends one use, and a skip if the cooldown is open and the caller asked to
   * spend one.
   *
   * <p>Spending a skip is explicit. Doing it automatically would burn something
   * scarce on a user who only wanted to know whether they could.
   */
  @Transactional
  public EntitlementState spendUse(UUID deviceId, boolean spendSkip) {
    Entitlement entitlement = rowFor(deviceId);
    Instant now = clock.instant();

    if (!entitlement.isPremium()) {
      if (remainingUses(entitlement) <= 0) {
        throw new CustomRuntimeException(402, "no_uses_left", "The free uses are spent.");
      }

      Instant openUntil = cooldownUntil(entitlement, now);
      if (openUntil != null) {
        if (!spendSkip) {
          throw new CustomRuntimeException(
              409, "cooldown_open", "The next motto is not available yet.");
        }
        if (entitlement.skipsLeft() <= 0) {
          throw new CustomRuntimeException(409, "no_skips_left", "No cooldown skip is left.");
        }
        entitlement.spendSkip();
      }
    }

    entitlement.recordClaim(now);
    return describe(entitlement);
  }

  /**
   * Removes what this device left behind, and keeps what stops it starting over.
   *
   * <p>There is nothing else to remove yet. The endpoint and this method exist
   * before there is, because the rule that has to survive every future table is
   * the one written here: the row that counts uses is not user data to be
   * deleted, and a test says so.
   */
  @Transactional
  public void deleteDataKeepingCounter(UUID deviceId) {
    rowFor(deviceId);
  }

  private Entitlement rowFor(UUID deviceId) {
    Entitlement existing = repository.findById(deviceId);
    if (existing != null) {
      return existing;
    }
    Entitlement fresh = Entitlement.forDevice(deviceId, skipsAtStart, clock.instant());
    repository.persist(fresh);
    return fresh;
  }

  private EntitlementState describe(Entitlement entitlement) {
    Instant now = clock.instant();
    return new EntitlementState(
        remainingUses(entitlement),
        cooldownUntil(entitlement, now),
        entitlement.skipsLeft(),
        entitlement.isPremium());
  }

  private int remainingUses(Entitlement entitlement) {
    return Math.max(0, freeUses - entitlement.usedCount());
  }

  /** When the cooldown ends, or null when it is not running. */
  private Instant cooldownUntil(Entitlement entitlement, Instant now) {
    if (entitlement.lastClaimAt() == null) {
      return null;
    }
    Instant until = entitlement.lastClaimAt().plus(cooldown);
    return until.isAfter(now) ? until : null;
  }
}
