package com.dafalabs.api.auth.otp;

/**
 * Whether a code is accepted without matching the one that was issued.
 *
 * <p>An interface with two implementations chosen at build time, rather than a
 * configuration flag. A flag can be turned on in production by an environment
 * variable nobody meant to set; a build-profile bean cannot, because the
 * accepting implementation is not compiled into the packaged application at
 * all. For a door that skips proving an identity, "cannot" is worth the extra
 * type.
 */
public interface OtpOverride {

  boolean accepts(String code);
}
