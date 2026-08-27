package com.dafalabs.api.motto.entitlement.dto;

import java.time.Instant;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param remainingUses free uses left; ignore it when premium is true
 * @param cooldownUntil when the next motto becomes available, null when it is
 *     available now. The one field here that is genuinely absent sometimes, and
 *     the only one left optional. Decided by the server: the device's own clock
 *     is a setting.
 * @param skipsLeft cooldown skips the device holds
 * @param premium unlimited use, no cooldown
 */
public record EntitlementResponse(
    @Schema(required = true) int remainingUses,
    Instant cooldownUntil,
    @Schema(required = true) int skipsLeft,
    @Schema(required = true) boolean premium) {}
