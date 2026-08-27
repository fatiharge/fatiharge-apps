package com.dafalabs.api.motto.report.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param reading the dimension text for the band this profile lands in — the
 *     part two people with the same archetype do not share
 */
public record ReportSection(
    @Schema(required = true) int section,
    @Schema(required = true) String opening,
    @Schema(required = true) String reading,
    @Schema(required = true) String fragment) {}
