package com.dafalabs.api.motto.entitlement;

import java.time.Instant;

/**
 * What a device may do right now, decided against the server's clock.
 *
 * @param remainingUses free uses left; meaningless once premium
 * @param cooldownUntil when the next motto becomes available, or null
 * @param skipsLeft cooldown skips the device still holds
 * @param premium unlimited use, no cooldown
 */
public record EntitlementState(
    int remainingUses, Instant cooldownUntil, int skipsLeft, boolean premium) {

  public boolean cooldownOpen() {
    return cooldownUntil != null;
  }

  public boolean canClaimNow() {
    return premium || (remainingUses > 0 && !cooldownOpen());
  }
}
