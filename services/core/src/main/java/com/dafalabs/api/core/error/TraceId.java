package com.dafalabs.api.core.error;

import java.util.UUID;
import org.jboss.logging.MDC;

/** Correlates an error response with the log line that describes it. */
final class TraceId {

  private TraceId() {}

  /**
   * Prefers the tracing id already in scope so the response points at the same
   * trace the logs use. Falls back to a fresh id, which is still worth
   * returning: without one, a user reporting "it failed" gives nothing to
   * search for.
   */
  static String current() {
    Object existing = MDC.get("traceId");
    if (existing != null && !existing.toString().isBlank()) {
      return existing.toString();
    }
    return UUID.randomUUID().toString();
  }
}
