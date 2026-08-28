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
 * @param markedDays this period's days only — a finished period's days stay in
 *     the database but stop being this chain's
 * @param mottoId which of the archetype's mottos this period runs under; null
 *     means the first
 * @param periodDone fourteen days marked. The run is over and the next one is
 *     waiting to be started
 */
public record ChainState(
    @Schema(required = true) boolean started,
    LocalDate startedOn,
    @Schema(required = true) List<MarkedDay> markedDays,
    LocalDate freezeUsedOn,
    @Schema(required = true) int streak,
    @Schema(required = true) boolean markedToday,
    @Schema(required = true) boolean broken,
    @Schema(required = true) boolean canFreeze,
    @Schema(required = true) int period,
    String mottoId,
    @Schema(required = true) boolean periodDone) {}
