package com.dafalabs.api.motto.chain.dto;

import java.time.LocalDate;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One day of the chain.
 *
 * <p>An object rather than a bare date in a list, for two reasons. The
 * generator emits `DateTime.listFromJson` for an array of dates and no such
 * method exists, so the Dart client would not compile. And the period report
 * has to tell a day someone marked from one the make-up covered.
 */
public record MarkedDay(
    @Schema(required = true) LocalDate day,
    @Schema(required = true) boolean madeUp) {}
