package com.dafalabs.api.motto.task.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param day which of the fourteen this is
 * @param tasks empty when there is no result yet: there is nothing to ask of
 *     someone the app knows nothing about
 */
public record DailyTasks(
    @Schema(required = true) int day,
    @Schema(required = true) List<DailyTask> tasks) {}
