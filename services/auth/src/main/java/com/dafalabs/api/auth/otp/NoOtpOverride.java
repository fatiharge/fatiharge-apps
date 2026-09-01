package com.dafalabs.api.auth.otp;

import io.quarkus.arc.profile.UnlessBuildProfile;
import jakarta.enterprise.context.ApplicationScoped;

/** Everywhere that is not development: nothing is accepted but the real code. */
@ApplicationScoped
@UnlessBuildProfile("dev")
public class NoOtpOverride implements OtpOverride {

  @Override
  public boolean accepts(String code) {
    return false;
  }
}
