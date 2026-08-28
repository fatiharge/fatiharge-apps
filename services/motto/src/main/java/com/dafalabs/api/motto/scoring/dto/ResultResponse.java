package com.dafalabs.api.motto.scoring.dto;

import com.dafalabs.api.motto.entitlement.dto.EntitlementResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param id the stored result this claim created, so the deep report can be
 *     opened without a second call to find out which one it was
 * @param archetype what the inventory produced
 * @param entitlement what is left afterwards, so the app does not need a second
 *     call to know whether the next one is available
 */
public record ResultResponse(
    @Schema(required = true) long id,
    @Schema(required = true) ArchetypeResponse archetype,
    @Schema(required = true) EntitlementResponse entitlement) {}
