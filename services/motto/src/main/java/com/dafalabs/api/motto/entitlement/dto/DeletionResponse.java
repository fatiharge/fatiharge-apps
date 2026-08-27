package com.dafalabs.api.motto.entitlement.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param deleted what was removed
 * @param kept what deliberately was not, so that the answer to "why are my free
 *     uses still gone" is in the response rather than only in a support reply
 */
public record DeletionResponse(
    @Schema(required = true) List<String> deleted,
    @Schema(required = true) List<String> kept) {}
