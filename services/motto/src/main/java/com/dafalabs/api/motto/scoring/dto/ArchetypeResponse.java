package com.dafalabs.api.motto.scoring.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** @param confident false when the answers were too few to separate the eight */
public record ArchetypeResponse(
    @Schema(required = true) String id,
    @Schema(required = true) String name,
    @Schema(required = true) String summary,
    @Schema(required = true) String motto,
    @Schema(required = true) boolean confident) {}
