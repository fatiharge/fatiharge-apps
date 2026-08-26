package com.dafalabs.api.core.error;

/**
 * The body every failing endpoint returns, whatever went wrong.
 *
 * @param code    stable, machine-readable, snake_case. Clients branch on this;
 *                messages are free to change wording, codes are not.
 * @param message for people. Never carries internal detail on a 5xx.
 * @param traceId ties this response to the server log line that explains it.
 */
public record ErrorResponse(String code, String message, String traceId) {}
