package com.dafalabs.api.motto.content.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** The part of a day that makes it one person's rather than anyone's. */
public record Fragment(
    @Schema(required = true) String archetypeId,
    @Schema(required = true) int index,
    @Schema(required = true) String text) {}
