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
// Registered by hand because nothing declares this type. Quarkus finds the
// bodies to keep reflection metadata for by reading resource method
// signatures, and this one is only ever built inside an exception mapper — so
// in a native image Jackson had no metadata for it, serialisation failed, and
// the caller got the framework's own text/plain error page with a 500 instead
// of this contract. The JVM tests cannot see that; ErrorContractIT can.
@RegisterForReflection
public record ErrorResponse(String code, String message, String traceId) {}
