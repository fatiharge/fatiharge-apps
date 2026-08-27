package com.dafalabs.api.motto.events.dto;

import java.time.Instant;
import java.util.Map;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param clientId generated on the phone. A retry after a timeout that actually
 *     landed would otherwise inflate exactly the numbers this exists to
 *     measure, so the server rejects a second one with the same id.
 * @param name one of the names the product asks questions about
 * @param occurredAt when it happened on the phone, which is not when it arrived
 * @param properties whatever that event carries, if anything
 */
public record EventEntry(
    @Schema(required = true) String clientId,
    @Schema(required = true) String name,
    @Schema(required = true) Instant occurredAt,
    Map<String, String> properties) {}
