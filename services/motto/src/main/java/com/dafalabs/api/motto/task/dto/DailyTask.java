package com.dafalabs.api.motto.task.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param detail why this one, and what doing it looks like. A task without a
 *     place to read it is a checkbox.
 */
public record DailyTask(
    @Schema(required = true) long id,
    @Schema(required = true) int ordinal,
    @Schema(required = true) String title,
    @Schema(required = true) String detail,
    @Schema(required = true) boolean done) {}
