package com.dafalabs.api.motto.chain;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.chain.dto.ChainState;
import com.dafalabs.api.motto.chain.dto.MarkedDay;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.UUID;
import java.util.stream.Collectors;

/** The chain, and the only place its rules are enforced. */
@ApplicationScoped
public class Chains {

  /// How far back a mark may be dated. Long enough for a phone that queued it
  /// offline, short enough that nobody backfills a month-long streak.
  static final int backdateDays = 7;

  /// Time zones span more than a day end to end, so a client's local date is
  /// legitimately the server's ± 1. Anything outside that was made up.
  static final int clockSkewDays = 1;

  private final ChainRepository chains;
  private final ChainDayRepository days;
  private final Clock clock;

  Chains(ChainRepository chains, ChainDayRepository days, Clock clock) {
    this.chains = chains;
    this.days = days;
    this.clock = clock;
  }

  @Transactional
  public ChainState start(UUID deviceId, LocalDate today) {
    verify(today);
    if (chains.findById(deviceId) == null) {
      chains.persist(Chain.startedBy(deviceId, today));
    }
    return mark(deviceId, today, today);
  }

  @Transactional
  public ChainState mark(UUID deviceId, LocalDate day, LocalDate today) {
    verify(day);
    verify(today);
    if (day.isBefore(serverToday().minusDays(backdateDays))) {
      throw new CustomRuntimeException(400, "day_too_old", "That day can no longer be marked.");
    }

    Chain chain = chains.findById(deviceId);
    if (chain == null) {
      chain = Chain.startedBy(deviceId, day);
      chains.persist(chain);
    }

    // Marking the same day twice is marking it once — and the offline queue
    // will send it twice sooner or later.
    if (!days.exists(deviceId, day)) {
      days.persist(ChainDay.of(deviceId, day, false, chain.period()));
    }
    return state(deviceId, today);
  }

  @Transactional
  public ChainState freeze(UUID deviceId, LocalDate today) {
    verify(today);
    Chain chain = chains.findById(deviceId);
    if (chain == null) {
      throw new CustomRuntimeException(409, "no_chain", "There is no chain to make up.");
    }

    Set<LocalDate> marked = markedDays(deviceId);
    if (!ChainRules.canFreezeOn(marked, chain.freezeUsedOn(), today)) {
      throw new CustomRuntimeException(
          409, "cannot_freeze", "The make-up does not apply right now.");
    }

    days.persist(ChainDay.of(deviceId, today.minusDays(1), true, chain.period()));
    chain.spendFreeze(today);
    return state(deviceId, today);
  }

  @Transactional
  public ChainState state(UUID deviceId, LocalDate today) {
    verify(today);
    Chain chain = chains.findById(deviceId);
    if (chain == null) {
      return new ChainState(false, null, List.of(), null, 0, false, false, false, 1, null, false);
    }

    Set<LocalDate> marked = markedDays(deviceId);
    List<MarkedDay> reported =
        days.forPeriod(deviceId, chain.period()).stream()
            .sorted(java.util.Comparator.comparing(ChainDay::day))
            .map(day -> new MarkedDay(day.day(), day.madeUp()))
            .toList();

    return new ChainState(
        true,
        chain.startedOn(),
        reported,
        chain.freezeUsedOn(),
        ChainRules.streakOn(marked, today),
        marked.contains(today),
        ChainRules.isBrokenOn(marked, today),
        ChainRules.canFreezeOn(marked, chain.freezeUsedOn(), today),
        chain.period(),
        chain.mottoId(),
        ChainRules.periodDone(reported.size()));
  }

  /**
   * Starts the next run, under a different motto.
   *
   * <p>Only once the fourteen days are actually done. Letting somebody restart
   * early would make the period mean nothing, and the period is the product.
   */
  @Transactional
  public ChainState nextPeriod(UUID deviceId, String mottoId, LocalDate today) {
    verify(today);
    Chain chain = chains.findById(deviceId);
    if (chain == null) {
      throw new CustomRuntimeException(409, "no_chain", "There is no chain to continue.");
    }
    if (!ChainRules.periodDone(days.forPeriod(deviceId, chain.period()).size())) {
      throw new CustomRuntimeException(
          409, "period_unfinished", "The fourteen days are not done yet.");
    }

    chain.beginNextPeriod(today, mottoId);
    return state(deviceId, today);
  }

  @Transactional
  public void deleteForDevice(UUID deviceId) {
    days.delete("deviceId", deviceId);
    chains.delete("deviceId", deviceId);
  }

  private Set<LocalDate> markedDays(UUID deviceId) {
    return days.forDevice(deviceId).stream()
        .map(ChainDay::day)
        .collect(Collectors.toCollection(TreeSet::new));
  }

  private LocalDate serverToday() {
    return LocalDate.now(clock.withZone(ZoneOffset.UTC));
  }

  private void verify(LocalDate claimed) {
    LocalDate today = serverToday();
    if (claimed.isAfter(today.plusDays(clockSkewDays))
        || claimed.isBefore(today.minusDays(365))) {
      throw new CustomRuntimeException(400, "impossible_date", "That is not a date.");
    }
  }
}
