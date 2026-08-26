package com.dafalabs.api.core.error;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class ErrorPayloadsTest {

  private static final String TRACE = "trace-1";

  @Test
  @DisplayName("a client error keeps its status, code and message")
  void clientErrorIsPassedThrough() {
    var exception = new CustomRuntimeException(404, "device_not_found", "No such device.");

    ErrorPayload payload = ErrorPayloads.of(exception, TRACE);

    assertEquals(404, payload.status());
    assertEquals("device_not_found", payload.body().code());
    assertEquals("No such device.", payload.body().message());
    assertEquals(TRACE, payload.body().traceId());
  }

  @Test
  @DisplayName("a server error keeps its code but never leaks its message")
  void serverErrorMessageIsReplaced() {
    var exception =
        new CustomRuntimeException(500, "store_unreachable", "jdbc://user:pw@db timed out");

    ErrorPayload payload = ErrorPayloads.of(exception, TRACE);

    assertEquals(500, payload.status());
    assertEquals("store_unreachable", payload.body().code());
    assertEquals(ErrorPayloads.SERVER_MESSAGE, payload.body().message());
    assertNotEquals(exception.getMessage(), payload.body().message());
  }

  @Test
  @DisplayName("an exception with no message still produces a body")
  void missingMessageBecomesEmpty() {
    ErrorPayload payload =
        ErrorPayloads.of(new CustomRuntimeException(409, "cooldown_open", null), TRACE);

    assertEquals("", payload.body().message());
  }

  @Test
  @DisplayName("anything unforeseen becomes a plain 500")
  void unforeseenIsGeneric() {
    ErrorPayload payload = ErrorPayloads.of(TRACE);

    assertEquals(500, payload.status());
    assertEquals(ErrorPayloads.SERVER_CODE, payload.body().code());
    assertEquals(ErrorPayloads.SERVER_MESSAGE, payload.body().message());
    assertEquals(TRACE, payload.body().traceId());
  }
}
