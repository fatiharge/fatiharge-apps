package com.dafalabs.api.motto.scoring.dto;

import com.dafalabs.api.motto.entitlement.dto.EntitlementResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param archetype what the test produced
 * @param entitlement what is left afterwards, so the app does not need a second
 *     call to know whether the next one is available
 */
public record ResultResponse(
    @Schema(required = true) ArchetypeResponse archetype,
    @Schema(required = true) EntitlementResponse entitlement) {}
