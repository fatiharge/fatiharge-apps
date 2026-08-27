package com.dafalabs.api.motto.events.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param events sent in batches because a phone that is offline queues them and
 *     a phone that is online should not make one request per tap
 */
public record EventBatch(
    @Schema(required = true) List<EventEntry> events) {}
