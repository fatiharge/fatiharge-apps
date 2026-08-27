package com.dafalabs.api.core.error;

import jakarta.ws.rs.core.Response;
import java.util.Locale;

/**
 * Turns a throwable into the response body.
 *
 * <p>Separate from the mappers on purpose: deciding what to return is pure, and
 * pure code can be tested without standing up a server.
 *
 * <p>Messages here are English and written for whoever is reading a log or a
 * failing request. They are never what a user sees: the client renders its own
 * text from {@code code}, which is why the code is the part that may not change
 * once something depends on it.
 */
final class ErrorPayloads {

  /** What a 5xx tells the caller. The real reason goes to the log, not the wire. */
  static final String SERVER_MESSAGE = "Unexpected server error.";

  static final String SERVER_CODE = "internal_error";

  private ErrorPayloads() {}

  static ErrorPayload of(CustomRuntimeException exception, String traceId) {
    boolean serverFault = exception.status() >= 500;
    String message = serverFault ? SERVER_MESSAGE : nullSafe(exception.getMessage());
    return new ErrorPayload(
        exception.status(), new ErrorResponse(exception.code(), message, traceId));
  }

  static ErrorPayload of(String traceId) {
    return new ErrorPayload(500, new ErrorResponse(SERVER_CODE, SERVER_MESSAGE, traceId));
  }

  /**
   * For a failure the framework raised before any of our code ran — an unknown
   * path, the wrong method, a body it would not parse.
   *
   * <p>The code is derived from the status rather than listed, so a status we
   * have never thought about still arrives as something a client can branch on
   * instead of as {@code internal_error}.
   */
  static ErrorPayload ofStatus(int status, String traceId) {
    if (status >= 500) {
      return of(traceId);
    }

    Response.Status known = Response.Status.fromStatusCode(status);
    String code = known == null ? "http_" + status : known.name().toLowerCase(Locale.ROOT);
    String message = known == null ? "" : known.getReasonPhrase() + ".";

    return new ErrorPayload(status, new ErrorResponse(code, message, traceId));
  }

  private static String nullSafe(String message) {
    return message == null ? "" : message;
  }
}
