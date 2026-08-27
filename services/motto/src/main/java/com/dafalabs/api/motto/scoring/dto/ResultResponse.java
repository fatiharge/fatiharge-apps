package com.dafalabs.api.motto.scoring.dto;

import com.dafalabs.api.motto.entitlement.dto.EntitlementResponse;

/**
 * @param archetype what the test produced
 * @param entitlement what is left afterwards, so the app does not need a second
 *     call to know whether the next one is available
 */
public record ResultResponse(ArchetypeResponse archetype, EntitlementResponse entitlement) {}
