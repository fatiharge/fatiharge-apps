package com.dafalabs.api.motto.content.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record ArchetypeContent(
    @Schema(required = true) String id,
    @Schema(required = true) String name,
    @Schema(required = true) String summary,
    @Schema(required = true) String motto) {}
