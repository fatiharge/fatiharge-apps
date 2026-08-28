package com.dafalabs.api.motto.chain;

import com.dafalabs.api.core.error.CustomRuntimeException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * Reads the phone's local date off a query string.
 *
 * <p>A `String` rather than a typed `LocalDate` parameter, and that is not
 * laziness. The generated Dart client serialises every query-parameter date as
 * `value.toUtc().toIso8601String()` — which the server cannot parse as a date,
 * and which has already moved the day for anyone east of UTC by the time it
 * arrives. A local day cannot be recovered from an instant, so the format has
 * to be settled on the wire.
 */
public abstract sealed class LocalDates permits LocalDates.None {

  private LocalDates() {}

  public static LocalDate parse(String value) {
    if (value == null || value.isBlank()) {
      throw new CustomRuntimeException(
          400, "missing_date", "Send the phone's local date as yyyy-MM-dd.");
    }
    try {
      return LocalDate.parse(value);
    } catch (DateTimeParseException malformed) {
      throw new CustomRuntimeException(
          400, "invalid_date", "That is not a date. Use yyyy-MM-dd.");
    }
  }

  static final class None extends LocalDates {}
}
