package com.dafalabs.api.motto.result.dto;

import com.dafalabs.api.motto.scoring.dto.ArchetypeResponse;
import java.time.Instant;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One entry in the archive.
 *
 * @param profile carried so the deep report can be assembled without a second
 *     round trip; two people with the same archetype do not read the same
 *     report.
 */
public record ResultSummary(
    @Schema(required = true) long id,
    @Schema(required = true) ArchetypeResponse archetype,
    @Schema(required = true) ProfileScores profile,
    @Schema(required = true) Instant claimedAt) {}
