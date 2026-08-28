package com.dafalabs.api.motto.admin;

import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.Provider;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Optional;
import org.eclipse.microprofile.config.ConfigProvider;

/**
 * The one door into the content tables, and it is shut unless a deployment
 * opens it.
 *
 * <p>Fails closed: with no token configured every call is refused, so a
 * deployment that forgets the variable is locked rather than open. The compare
 * is constant-time because the answer to a wrong token is otherwise a timing
 * oracle for the right one.
 */
@Provider
@AdminOnly
@Priority(Priorities.AUTHENTICATION)
public class AdminTokenFilter implements ContainerRequestFilter {

  static final String HEADER = "X-Admin-Token";

  /**
   * Looked up on the first request rather than injected.
   *
   * <p>A {@code @Provider} is constructed during static initialisation, and a
   * native image runs that at build time, where there is no environment to read
   * — so the token would be baked in as null and Quarkus refuses to start when
   * the runtime value disagrees. It is right to refuse: the alternative is an
   * image that silently ships with the door welded shut.
   */
  private volatile Optional<String> expected;

  private Optional<String> expected() {
    Optional<String> known = expected;
    if (known == null) {
      known =
          ConfigProvider.getConfig()
              .getOptionalValue("motto.admin.token", String.class)
              .filter(token -> !token.isBlank());
      expected = known;
    }
    return known;
  }

  @Override
  public void filter(ContainerRequestContext request) {
    Optional<String> wanted = expected();
    String offered = request.getHeaderString(HEADER);
    if (wanted.isEmpty() || offered == null || !matches(wanted.get(), offered)) {
      request.abortWith(
          Response.status(Response.Status.NOT_FOUND)
              .type(MediaType.APPLICATION_JSON)
              .entity("{\"code\":\"not_found\",\"message\":\"Not found.\"}")
              .build());
    }
  }

  /// 404 rather than 401 above: an endpoint nobody is meant to know about
  /// should not confirm it exists to somebody guessing.
  private static boolean matches(String expected, String offered) {
    return MessageDigest.isEqual(
        expected.getBytes(StandardCharsets.UTF_8), offered.getBytes(StandardCharsets.UTF_8));
  }
}
