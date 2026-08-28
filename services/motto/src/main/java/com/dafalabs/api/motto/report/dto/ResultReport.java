package com.dafalabs.api.motto.report.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * The report everybody gets, free, in full.
 *
 * <p>Not a shortened deep report. This one answers what the reader is — all
 * five dimensions, read one by one — and stops there. The deep report answers
 * what it means and what it costs, woven per profile, and that is what is sold.
 * Two whole documents rather than one document and its teaser.
 */
public record ResultReport(
    @Schema(required = true) long resultId,
    @Schema(required = true) String archetypeId,
    @Schema(required = true) String overview,
    @Schema(required = true) List<DimensionReading> readings,
    @Schema(required = true) String strength,
    @Schema(required = true) String cost) {}
