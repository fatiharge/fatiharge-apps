package com.dafalabs.api.core.error;

/**
 * Base for every exception that is allowed to reach an endpoint boundary.
 *
 * <p>The exception carries its own HTTP status, so a resource never has to
 * decide one: it throws, and {@link CustomExceptionMapper} renders it. Catching
 * an exception in a resource to turn it into a status code is the thing this
 * type exists to remove.
 */
public class CustomRuntimeException extends RuntimeException {

  private final int status;
  private final String code;

  public CustomRuntimeException(int status, String code, String message) {
    this(status, code, message, null);
  }

  public CustomRuntimeException(int status, String code, String message, Throwable cause) {
    super(message, cause);
    this.status = status;
    this.code = code;
  }

  public int status() {
    return status;
  }

  public String code() {
    return code;
  }
}
