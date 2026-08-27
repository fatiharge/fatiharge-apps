package com.dafalabs.api.core.error;

import jakarta.ws.rs.core.Response;
import java.util.Locale;

/**
 * Turns a throwable into the response body.
 *
 * <p>Separate from the mappers so it can be tested without a server. Messages
 * are for whoever reads a log; the client renders its own text from {@code
 * code}, which is why the code may not change once something depends on it.
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
   * For a failure the framework raised before any of our code ran. The code is
   * derived from the status, so one nobody listed still arrives as something a
   * client can branch on.
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
