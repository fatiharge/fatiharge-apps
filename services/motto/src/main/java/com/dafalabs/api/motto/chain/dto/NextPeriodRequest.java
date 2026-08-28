package com.dafalabs.api.motto.chain.dto;

import java.time.LocalDate;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Start the next fourteen days under a different motto.
 *
 * @param mottoId one of the archetype's four. Null keeps the one this period
 *     ran under, which is a legitimate choice: some people want the same
 *     sentence again.
 */
public record NextPeriodRequest(
    @Schema(required = true) LocalDate day, String mottoId) {}
