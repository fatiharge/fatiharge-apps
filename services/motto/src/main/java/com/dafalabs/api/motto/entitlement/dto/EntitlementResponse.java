package com.dafalabs.api.motto.entitlement.dto;

import java.time.Instant;

/**
 * @param remainingUses free uses left; ignore it when premium is true
 * @param cooldownUntil when the next motto becomes available, null when it is
 *     available now. Decided by the server: the device's own clock is a setting.
 * @param skipsLeft cooldown skips the device holds
 * @param premium unlimited use, no cooldown
 */
public record EntitlementResponse(
    int remainingUses, Instant cooldownUntil, int skipsLeft, boolean premium) {}
