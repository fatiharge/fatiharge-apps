package com.dafalabs.api.core.error;

import io.quarkus.runtime.annotations.RegisterForReflection;

/**
 * The body every failing endpoint returns, whatever went wrong.
 *
 * @param code    stable, machine-readable, snake_case. Clients branch on this;
 *                messages are free to change wording, codes are not.
 * @param message for people. Never carries internal detail on a 5xx.
 * @param traceId ties this response to the server log line that explains it.
 */
// Registered by hand: Quarkus finds bodies to keep reflection metadata for by
// reading resource signatures, and this one is only built inside an exception
// mapper. Without it the native image cannot serialise this and answers the
// framework's own error page instead. ErrorContractIT is what catches it.
@RegisterForReflection
public record ErrorResponse(String code, String message, String traceId) {}
