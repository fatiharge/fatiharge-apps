package com.dafalabs.api.motto.chain.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One run of fourteen, and the days that were marked in it.
 *
 * <p>The days come back in date order, which is what makes them readable: the
 * first is that run's day one, the second its day two. The app needs that
 * position to know which of the fourteen texts somebody was given, and the
 * server does not have to send the text to say which one it was.
 *
 * @param period the run's number, counting from one
 * @param current true for the run still going
 */
public record ChainPeriod(
    @Schema(required = true) int period,
    @Schema(required = true) boolean current,
    @Schema(required = true) List<MarkedDay> days) {}
