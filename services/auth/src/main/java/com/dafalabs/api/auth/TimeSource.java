package com.dafalabs.api.auth;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;
import java.time.Clock;

/**
 * Time arrives through a {@link Clock} so that tests can fix it. Reading the
 * wall clock directly is what makes a token-expiry test flaky at midnight.
 */
public class TimeSource {

  @Produces
  @ApplicationScoped
  Clock systemClock() {
    return Clock.systemUTC();
  }
}
