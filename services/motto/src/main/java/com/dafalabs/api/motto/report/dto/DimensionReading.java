package com.dafalabs.api.motto.report.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Where one profile lands on one dimension, and what that reads as.
 *
 * @param score kept alongside the text so the screen can draw the position
 *     rather than only assert it — a bar somebody can see themselves on is
 *     harder to dismiss than a sentence
 */
public record DimensionReading(
    @Schema(required = true) String dimension,
    @Schema(required = true) String band,
    @Schema(required = true) double score,
    @Schema(required = true) String text) {}
