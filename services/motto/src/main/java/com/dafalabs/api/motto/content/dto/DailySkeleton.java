package com.dafalabs.api.motto.content.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One of the fourteen days, without the person in it.
 *
 * @param action the minute. It has to be doable while standing in a queue.
 */
public record DailySkeleton(
    @Schema(required = true) int day,
    @Schema(required = true) String title,
    @Schema(required = true) String body,
    @Schema(required = true) String action) {}
