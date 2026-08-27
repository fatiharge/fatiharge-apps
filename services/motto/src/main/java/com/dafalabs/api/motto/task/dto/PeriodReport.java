package com.dafalabs.api.motto.task.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * What fourteen days came to.
 *
 * @param daysMarked how many days were marked at all
 * @param daysMadeUp of those, how many the make-up covered rather than someone
 *     marking them — a period report that counts them as the same thing is
 *     flattering rather than useful
 * @param tasksDone out of {@code tasksOffered}
 * @param complete false while the period is still running
 */
public record PeriodReport(
    @Schema(required = true) int day,
    @Schema(required = true) int daysMarked,
    @Schema(required = true) int daysMadeUp,
    @Schema(required = true) int tasksDone,
    @Schema(required = true) int tasksOffered,
    @Schema(required = true) boolean complete) {}
