package com.dafalabs.api.motto.events.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param accepted how many were stored
 * @param duplicates how many had been sent before. Reported rather than hidden:
 *     a client that keeps resending is a bug worth seeing from the outside.
 */
public record EventBatchResponse(
    @Schema(required = true) int accepted,
    @Schema(required = true) int duplicates) {}
