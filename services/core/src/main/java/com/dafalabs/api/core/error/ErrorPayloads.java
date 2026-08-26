package com.dafalabs.api.core.error;

/**
 * Turns a throwable into the response body.
 *
 * <p>Separate from the mappers on purpose: deciding what to return is pure, and
 * pure code can be tested without standing up a server.
 */
final class ErrorPayloads {

  /** What a 5xx tells the caller. The real reason goes to the log, not the wire. */
  static final String SERVER_MESSAGE = "Beklenmeyen bir hata oluştu.";

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

  private static String nullSafe(String message) {
    return message == null ? "" : message;
  }
}
