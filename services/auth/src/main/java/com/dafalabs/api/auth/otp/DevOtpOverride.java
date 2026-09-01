package com.dafalabs.api.auth.otp;

import io.quarkus.arc.profile.IfBuildProfile;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * One code that always works, in development only.
 *
 * <p>Development has no inbox: the code is written to the outbox and read out
 * of the database by hand. That is fine once and tedious every time, and the
 * tedium is what makes people leave themselves signed in and stop exercising
 * the sign-in path at all.
 *
 * <p>{@link IfBuildProfile} rather than a flag: this class is not in the
 * packaged application. Tests run under the test profile and get {@link
 * NoOtpOverride}, so nothing here weakens what the tests prove.
 */
@ApplicationScoped
@IfBuildProfile("dev")
public class DevOtpOverride implements OtpOverride {

  private static final String ALWAYS_WORKS = "111111";

  @Override
  public boolean accepts(String code) {
    return ALWAYS_WORKS.equals(code);
  }
}
