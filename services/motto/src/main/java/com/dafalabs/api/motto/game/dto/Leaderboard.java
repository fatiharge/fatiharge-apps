package com.dafalabs.api.motto.game.dto;

import java.time.LocalDate;
import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param week the Monday it belongs to
 * @param yourBest zero when this device has not played this week
 * @param rewardedRanks how many of the top places win the deep report
 */
public record Leaderboard(
    @Schema(required = true) LocalDate week,
    @Schema(required = true) List<LeaderboardEntry> entries,
    @Schema(required = true) int yourBest,
    @Schema(required = true) int rewardedRanks) {}
