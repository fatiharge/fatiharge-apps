package com.dafalabs.api.motto.result.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** Where a set of answers landed, each dimension between 0 and 1. */
public record ProfileScores(
    @Schema(required = true) double openness,
    @Schema(required = true) double conscientiousness,
    @Schema(required = true) double extraversion,
    @Schema(required = true) double agreeableness,
    @Schema(required = true) double neuroticism) {}
