package com.dafalabs.api.motto.chain.dto;

import java.time.LocalDate;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param day the day being marked, in the phone's local calendar. Sent rather
 *     than derived: the server's UTC date is the wrong day for most of the
 *     world for part of every day.
 * @param today what day it is on the phone now. The same as {@code day} for a
 *     mark made live, and older for one that was queued offline — the state
 *     that comes back is the state now, not the state on the day being marked.
 */
public record MarkDayRequest(
    @Schema(required = true) LocalDate day, LocalDate today) {

  public LocalDate todayOrDay() {
    return today == null ? day : today;
  }
}
