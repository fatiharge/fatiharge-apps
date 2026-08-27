package com.dafalabs.api.motto.chain.dto;

import java.time.LocalDate;
import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * The chain as it stands.
 *
 * @param streak counted against the date the client said it was, because a
 *     local day is the only day a streak is measured in
 * @param canFreeze true only when exactly one day was missed and this month's
 *     make-up is unspent
 */
public record ChainState(
    @Schema(required = true) boolean started,
    LocalDate startedOn,
    @Schema(required = true) List<MarkedDay> markedDays,
    LocalDate freezeUsedOn,
    @Schema(required = true) int streak,
    @Schema(required = true) boolean markedToday,
    @Schema(required = true) boolean broken,
    @Schema(required = true) boolean canFreeze) {}
