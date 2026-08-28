package com.dafalabs.api.motto.game.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param you true for the reader's own row — there is no name to show, so the
 *     only thing that makes a leaderboard readable is knowing which line is
 *     yours
 */
public record LeaderboardEntry(
    @Schema(required = true) int rank,
    @Schema(required = true) int points,
    @Schema(required = true) boolean you) {}
