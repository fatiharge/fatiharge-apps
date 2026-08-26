package com.dafalabs.api.core.error;

/** What to send back, decided before any JAX-RS type is involved. */
record ErrorPayload(int status, ErrorResponse body) {}
