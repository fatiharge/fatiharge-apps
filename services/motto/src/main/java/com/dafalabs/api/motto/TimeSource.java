package com.dafalabs.api.motto;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;
import java.time.Clock;

/**
 * Time arrives through a {@link Clock} so that tests can fix it. A cooldown test
 * that reads the wall clock either takes two weeks or proves nothing.
 */
public class TimeSource {

  @Produces
  @ApplicationScoped
  Clock systemClock() {
    return Clock.systemUTC();
  }
}
