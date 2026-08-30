package com.dafalabs.api.motto.game.dto;

/**
 * What today has paid for, and what is left of it.
 *
 * <p>The two flags are here so the app can say why there is nothing left. "Go
 * and finish the day first" and "come back tomorrow" are different sentences,
 * and a bare zero cannot tell them apart.
 */
public record PlayCredits(
    int remaining, int earned, int spent, boolean dayMarked, boolean tasksDone) {}
