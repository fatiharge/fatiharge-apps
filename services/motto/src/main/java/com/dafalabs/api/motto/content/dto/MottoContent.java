package com.dafalabs.api.motto.content.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param detail what this motto means and what it costs
 * @param reminder the line it becomes on a lock screen
 */
public record MottoContent(
    @Schema(required = true) String id,
    @Schema(required = true) String archetypeId,
    @Schema(required = true) String motto,
    @Schema(required = true) String detail,
    @Schema(required = true) String reminder) {}
